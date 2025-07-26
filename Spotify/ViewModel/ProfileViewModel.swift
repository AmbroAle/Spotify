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
        guard let userID = Auth.auth().currentUser?.uid else {
            username = "Ospite"
            email = ""
            userImageURL = nil
            return
        }

        let userDocRef = db.collection("users").document(userID)
        userDocRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                print("Errore fetch profilo: \(error.localizedDescription)")
                return
            }

            if let doc = document, doc.exists {
                self.username = doc.data()?["username"] as? String ?? "Sconosciuto"
                self.email = doc.data()?["email"] as? String ?? ""

                if let urlString = doc.data()?["profileImageURL"] as? String,
                   let url = URL(string: urlString) {
                    self.userImageURL = url
                }
            } else {
                print("Documento utente non trovato")
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
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
