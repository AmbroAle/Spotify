import Foundation
import FirebaseFirestore
import FirebaseAuth

class PlaylistLibraryViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func fetchPlaylists() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Utente non autenticato"
            return
        }

        isLoading = true
        db.collection("users").document(uid).collection("playlists")
            .order(by: "createdAt", descending: false)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "Errore nel caricamento: \(error.localizedDescription)"
                        return
                    }

                    self.playlists = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Playlist.self)
                    } ?? []
                }
            }
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Utente non autenticato"
            return
        }

        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            playlists.remove(at: index)
        }

        db.collection("users")
            .document(uid)
            .collection("playlists")
            .document(playlist.id)
            .delete { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Errore durante l'eliminazione: \(error.localizedDescription)"
                    }
                }
            }
    }
}
