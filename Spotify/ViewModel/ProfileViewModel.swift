//
//  ProfileViewModel.swift
//  Spotify
//
//  Created by Alex Frisoni on 27/07/25.
//

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

    private let db = Firestore.firestore()

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
                // Crea automaticamente il documento se non esiste
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

    func uploadProfileImage(_ imageData: Data) async throws -> URL {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "User not logged in", code: 0)
        }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("profileImages/\(userID).jpg")

        let _ = try await imageRef.putDataAsync(imageData)

        let downloadURL = try await imageRef.downloadURL()
        return downloadURL
    }

    func updateProfileImageURL(_ url: URL) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let userDocRef = db.collection("users").document(userID)
        userDocRef.updateData(["profileImageURL": url.absoluteString]) { error in
            if let error = error {
                print("Errore aggiornamento URL immagine: \(error.localizedDescription)")
            } else {
                print("URL immagine profilo aggiornato")
                Task { @MainActor in
                    self.userImageURL = url
                }
            }
        }
    }

    func changeProfileImage(_ imageData: Data) {
        Task {
            do {
                let url = try await uploadProfileImage(imageData)
                updateProfileImageURL(url)
            } catch {
                print("Errore upload immagine: \(error)")
            }
        }
    }
}
