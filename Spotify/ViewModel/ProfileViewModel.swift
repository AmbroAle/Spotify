import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var username: String = "Caricamento..."
    @Published var email: String = ""
    @Published var userImageURL: URL?
    @Published var pickedImageData: Data?
    @Published var savedProfileImages: [ProfileImageData] = [] //storico foto profilo

    private let db = Firestore.firestore()

    // MARK: - Gestione Profilo Base (codice esistente)
    
    func fetchUserProfile() {
        print("🔄 Inizio fetch profilo utente...")
        
        guard let currentUser = Auth.auth().currentUser else {
            print("Nessun utente autenticato")
            username = "Ospite"
            email = ""
            userImageURL = nil
            return
        }
        
        print("🔍 Recupero dati per UID: \(currentUser.uid)")
        
        let userDocRef = db.collection("users").document(currentUser.uid)
        userDocRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Errore fetch profilo: \(error.localizedDescription)")
                self.username = "Errore caricamento"
                return
            }

            if let doc = document, doc.exists {
                print("Documento utente trovato")
                let data = doc.data()
                print("📄 Dati ricevuti: \(data ?? [:])")
                
                self.username = data?["username"] as? String ?? "Sconosciuto"
                self.email = data?["email"] as? String ?? currentUser.email ?? ""

                if let urlString = data?["profileImageURL"] as? String, !urlString.isEmpty,
                   let url = URL(string: urlString) {
                    self.userImageURL = url
                    print("URL immagine profilo trovato: \(urlString)")
                } else {
                    print("Nessuna immagine profilo trovata")
                }
            } else {
                print("Documento utente non trovato, creazione automatica...")
                self.createMissingUserDocument(currentUser)
            }
        }
    }
    
    private func createMissingUserDocument(_ user: User) {
        let email = user.email ?? ""
        let username = String(email.split(separator: "@").first ?? "Utente")
        
        let userData: [String: Any] = [
            "username": username,
            "email": email,
            "createdAt": Timestamp(date: Date()),
            "profileImageURL": ""
        ]
        
        db.collection("users").document(user.uid).setData(userData) { [weak self] error in
            if let error = error {
                print("Errore creazione documento utente: \(error.localizedDescription)")
                self?.username = "Errore"
            } else {
                print("Documento utente creato automaticamente")
                self?.username = username
                self?.email = email
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            print("Logout effettuato")
        } catch {
            print("Errore logout: \(error.localizedDescription)")
        }
    }

    // MARK: - Gestione Foto Profilo (nuovo pattern simile ad AlbumDetailViewModel)
    
    func saveProfileImage(_ imageData: Data, description: String = "") {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        Task {
            do {
                // 1. Upload immagine su Storage
                let imageURL = try await uploadImageToStorage(imageData, userID: userID)
                
                // 2. Salva metadata nel database (stesso pattern delle tracce)
                let imageMetadata: [String: Any] = [
                    "imageURL": imageURL.absoluteString,
                    "description": description.isEmpty ? "Foto profilo del \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))" : description,
                    "timestamp": Timestamp(date: Date()),
                    "userID": userID
                ]
                
                let documentID = "\(Date().timeIntervalSince1970)"
                
                db.collection("users")
                    .document(userID)
                    .collection("profileImages")
                    .document(documentID)
                    .setData(imageMetadata) { [weak self] error in
                        if let error = error {
                            print("Errore salvataggio foto profilo: \(error.localizedDescription)")
                        } else {
                            print("Foto profilo salvata con successo")
                            // Refresh della lista
                            Task { @MainActor in
                                await self?.fetchSavedProfileImages()
                            }
                        }
                    }
                
            } catch {
                print("Errore upload foto profilo: \(error.localizedDescription)")
            }
        }
    }
    
    func removeSavedProfileImage(_ documentID: String, imageURL: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        db.collection("users")
            .document(userID)
            .collection("profileImages")
            .document(documentID)
            .delete { [weak self] error in
                if let error = error {
                    print("Errore rimozione foto profilo: \(error)")
                } else {
                    print("Foto profilo rimossa dal database")
                    // Rimuovi anche da Storage
                    self?.deleteImageFromStorage(imageURL)
                    // Refresh della lista
                    Task { @MainActor in
                        await self?.fetchSavedProfileImages()
                    }
                }
            }
    }
    
    func fetchSavedProfileImages() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        db.collection("users")
            .document(userID)
            .collection("profileImages")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Errore caricamento foto profilo salvate: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                let images = documents.compactMap { doc -> ProfileImageData? in
                    let data = doc.data()
                    guard let imageURL = data["imageURL"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else { return nil }
                    
                    return ProfileImageData(
                        id: doc.documentID,
                        imageURL: imageURL,
                        description: data["description"] as? String ?? "",
                        timestamp: timestamp
                    )
                }

                Task { @MainActor in
                    self?.savedProfileImages = images
                }
            }
    }
    
    func setAsCurrentProfileImage(_ imageURL: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(userID)
            .updateData(["profileImageURL": imageURL]) { [weak self] error in
                if let error = error {
                    print("Errore impostazione foto profilo corrente: \(error.localizedDescription)")
                } else {
                    print("Foto profilo corrente aggiornata")
                    Task { @MainActor in
                        self?.userImageURL = URL(string: imageURL)
                    }
                }
            }
    }

    // MARK: - Funzioni esistenti (mantenute per compatibilità)
    
    func uploadProfileImage(_ imageData: Data) async throws -> URL {
        return try await uploadImageToStorage(imageData, userID: Auth.auth().currentUser?.uid ?? "")
    }

    func updateProfileImageURL(_ url: URL) {
        setAsCurrentProfileImage(url.absoluteString)
    }

    func changeProfileImage(_ imageData: Data) {
        Task {
            do {
                // Upload immagine e ottieni URL
                let url = try await uploadProfileImage(imageData)

                // Aggiorna immagine profilo corrente
                updateProfileImageURL(url)

                // Salva nel database lo storico
                saveProfileImage(imageData)
            } catch {
                print("Errore upload immagine: \(error)")
            }
        }
    }

    
    // MARK: - Helper Functions Private
    
    private func uploadImageToStorage(_ imageData: Data, userID: String) async throws -> URL {
        let storageRef = Storage.storage().reference()
        let timestamp = Date().timeIntervalSince1970
        let imageRef = storageRef.child("profileImages/\(userID)/\(timestamp).jpg")
        
        let _ = try await imageRef.putDataAsync(imageData)
        let downloadURL = try await imageRef.downloadURL()
        return downloadURL
    }
    
    private func deleteImageFromStorage(_ imageURL: String) {
        let storageRef = Storage.storage().reference(forURL: imageURL)
        
        storageRef.delete { error in
            if let error = error {
                print("Errore eliminazione immagine da Storage: \(error.localizedDescription)")
            } else {
                print("Immagine eliminata da Storage")
            }
        }
    }
}

// MARK: - Struttura Dati
struct ProfileImageData: Identifiable, Codable {
    let id: String
    let imageURL: String
    let description: String
    let timestamp: Timestamp
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp.dateValue())
    }
}
