import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var username: String = "Caricamento..."
    @Published var email: String = ""
    @Published var userImageURL: URL?
    @Published var pickedImageData: Data?
    @Published var savedProfileImages: [ProfileImageData] = []

    private let db = Firestore.firestore()
    private let fileManager = FileManager.default
    private let imageFolderName = "ProfileImages"

    init() {
        createImagesDirectoryIfNeeded()
    }

    // MARK: - Gestione Profilo Firebase (mantiene funzionalità esistenti)
    
    func fetchUserProfile() {
        print("🔄 Inizio fetch profilo utente...")
        
        guard let currentUser = Auth.auth().currentUser else {
            print("Nessun utente autenticato")
            username = "Ospite"
            email = ""
            userImageURL = nil
            return
        }
        
        print("Recupero dati per UID: \(currentUser.uid)")
        print("Email utente corrente: \(currentUser.email ?? "N/A")")
        
        let userDocRef = db.collection("users").document(currentUser.uid)
        userDocRef.getDocument { [weak self] document, error in
            guard let self = self else {
                print("Self è nil")
                return
            }
            
            if let error = error {
                print("Errore fetch profilo: \(error.localizedDescription)")
                Task { @MainActor in
                    self.username = "Errore caricamento"
                }
                return
            }

            if let doc = document, doc.exists {
                print("Documento utente trovato")
                let data = doc.data()
                print("Dati ricevuti: \(data ?? [:])")
                
                let fetchedUsername = data?["username"] as? String ?? "Sconosciuto"
                let fetchedEmail = data?["email"] as? String ?? currentUser.email ?? ""
                
                print("Username estratto: '\(fetchedUsername)'")
                print("Email estratta: '\(fetchedEmail)'")
                
                Task { @MainActor in
                    self.username = fetchedUsername
                    self.email = fetchedEmail
                    print("Username e email aggiornati sulla UI")
                }

                if let urlString = data?["profileImageURL"] as? String, !urlString.isEmpty,
                   let url = URL(string: urlString) {
                    print("URL immagine profilo trovato: \(urlString)")
                    Task { @MainActor in
                        self.userImageURL = url
                    }
                } else {
                    print("Nessuna immagine profilo Firebase, controllo locale...")
                    self.loadLastLocalImage()
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
        
        print("🆕 Creazione documento per utente: \(username)")
        
        let userData: [String: Any] = [
            "username": username,
            "email": email,
            "createdAt": Timestamp(date: Date()),
            "profileImageURL": ""
        ]
        
        db.collection("users").document(user.uid).setData(userData) { [weak self] error in
            if let error = error {
                print("Errore creazione documento utente: \(error.localizedDescription)")
                Task { @MainActor in
                    self?.username = "Errore"
                }
            } else {
                print("Documento utente creato automaticamente con username: \(username)")
                Task { @MainActor in
                    self?.username = username
                    self?.email = email
                    print("Username aggiornato sulla UI: \(username)")
                }
            }
        }
    }

    // MARK: - Gestione Immagini Locali (nuova funzionalità)

    func changeProfileImage(_ imageData: Data) {
        pickedImageData = imageData
        saveProfileImageLocally(imageData)
        
        // Opzionale: salva anche su Firebase se l'utente è autenticato
        if Auth.auth().currentUser != nil {
            uploadToFirebaseAndUpdateProfile(imageData)
        }
    }

    private func saveProfileImageLocally(_ imageData: Data) {
        let timestamp = Date().timeIntervalSince1970
        let fileName = "profile_\(UUID().uuidString)_\(timestamp).jpg"
        
        guard let dirURL = getImagesDirectoryURL() else { return }
        let fileURL = dirURL.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL)
            print("Immagine salvata localmente in: \(fileURL.path)")

            let imageMeta = ProfileImageData(
                id: fileName,
                localPath: fileURL.path,
                description: "Foto profilo del \(formattedDate(from: Date()))",
                timestamp: Date()
            )

            savedProfileImages.insert(imageMeta, at: 0)
            userImageURL = fileURL

        } catch {
            print("Errore salvataggio immagine locale: \(error)")
        }
    }
    
    private func uploadToFirebaseAndUpdateProfile(_ imageData: Data) {
        Task {
            do {
                let url = try await uploadImageToStorage(imageData, userID: Auth.auth().currentUser?.uid ?? "")
                await updateFirebaseProfileImageURL(url.absoluteString)
            } catch {
                print("Errore upload Firebase: \(error)")
            }
        }
    }
    
    private func updateFirebaseProfileImageURL(_ urlString: String) async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection("users").document(userID).updateData(["profileImageURL": urlString])
            print("URL profilo aggiornato su Firebase")
        } catch {
            print("Errore aggiornamento Firebase: \(error)")
        }
    }

    func fetchSavedProfileImages() async {
        guard let dirURL = getImagesDirectoryURL() else { return }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [.creationDateKey])
            
            let images = contents.compactMap { url -> ProfileImageData? in
                guard fileManager.fileExists(atPath: url.path) else { return nil }
                
                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let creationDate = attributes?[.creationDate] as? Date ?? Date()
                
                return ProfileImageData(
                    id: url.lastPathComponent,
                    localPath: url.path,
                    description: "Foto profilo salvata",
                    timestamp: creationDate
                )
            }.sorted(by: { $0.timestamp > $1.timestamp })

            savedProfileImages = images
            
        } catch {
            print("Errore caricamento immagini locali: \(error)")
            savedProfileImages = []
        }
    }

    func setAsCurrentProfileImage(_ path: String) {
        // Verifica se è un path locale o un URL Firebase
        if path.hasPrefix("http") {
            // È un URL Firebase
            userImageURL = URL(string: path)
            if Auth.auth().currentUser != nil {
                Task {
                    await updateFirebaseProfileImageURL(path)
                }
            }
        } else {
            // È un path locale
            guard fileManager.fileExists(atPath: path) else {
                print("File immagine non trovato: \(path)")
                return
            }
            userImageURL = URL(fileURLWithPath: path)
        }
    }

    func removeSavedProfileImage(_ id: String) {
        guard let imageToDelete = savedProfileImages.first(where: { $0.id == id }) else { return }
        
        do {
            try fileManager.removeItem(atPath: imageToDelete.localPath)
            savedProfileImages.removeAll { $0.id == id }
            
            if userImageURL?.path == imageToDelete.localPath {
                userImageURL = nil
            }
            
            print("Immagine rimossa: \(imageToDelete.localPath)")
        } catch {
            print("Errore rimozione immagine: \(error)")
        }
    }
    
    private func loadLastLocalImage() {
        Task {
            await fetchSavedProfileImages()
            if let lastImage = savedProfileImages.first {
                userImageURL = URL(fileURLWithPath: lastImage.localPath)
            }
        }
    }

    // MARK: - Gestione Directory e Utility

    private func createImagesDirectoryIfNeeded() {
        guard let dirURL = getImagesDirectoryURL() else { return }
        
        if !fileManager.fileExists(atPath: dirURL.path) {
            do {
                try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
                print("Cartella immagini creata: \(dirURL.path)")
            } catch {
                print("Errore creazione cartella immagini: \(error)")
            }
        }
    }

    private func getImagesDirectoryURL() -> URL? {
        let base = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        return base?.appendingPathComponent(imageFolderName)
    }

    func cleanOldImages(olderThan days: Int = 30) {
        guard let dirURL = getImagesDirectoryURL() else { return }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [.creationDateKey])
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            
            for fileURL in contents {
                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                if let creationDate = attributes[.creationDate] as? Date,
                   creationDate < cutoffDate {
                    try fileManager.removeItem(at: fileURL)
                    print("Rimossa immagine vecchia: \(fileURL.lastPathComponent)")
                }
            }
            
            Task {
                await fetchSavedProfileImages()
            }
            
        } catch {
            print("Errore pulizia immagini: \(error)")
        }
    }

    func getCacheSize() -> String {
        guard let dirURL = getImagesDirectoryURL() else { return "0 KB" }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [.fileSizeKey])
            let totalSize: Int64 = contents.reduce(0) { total, url in
                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let fileSize = attributes?[.size] as? Int64 ?? 0
                return total + fileSize
            }
            
            return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
            
        } catch {
            print("Errore calcolo dimensione cache: \(error)")
            return "N/A"
        }
    }

    private func uploadImageToStorage(_ imageData: Data, userID: String) async throws -> URL {
        let storageRef = Storage.storage().reference()
        let timestamp = Date().timeIntervalSince1970
        let imageRef = storageRef.child("profileImages/\(userID)/\(timestamp).jpg")
        
        let _ = try await imageRef.putDataAsync(imageData)
        let downloadURL = try await imageRef.downloadURL()
        return downloadURL
    }

    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            print("Logout effettuato")
        } catch {
            print("Errore logout: \(error.localizedDescription)")
        }
    }
}

struct ProfileImageData: Identifiable, Codable {
    let id: String
    let localPath: String
    let description: String
    let timestamp: Date
    
    var fileURL: URL {
        URL(fileURLWithPath: localPath)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: timestamp)
    }
}
