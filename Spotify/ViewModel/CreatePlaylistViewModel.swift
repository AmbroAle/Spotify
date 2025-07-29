import Foundation
import FirebaseFirestore
import FirebaseAuth

class CreatePlaylistViewModel: ObservableObject {
    @Published var playlistName: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func savePlaylist() {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Utente non autenticato"
            return
        }

        isSaving = true
        let playlist = Playlist(name: playlistName, trackIDs: [], createdAt: Date())

        do {
            let data = try Firestore.Encoder().encode(playlist)
            db.collection("users").document(uid).collection("playlists").document(playlist.id).setData(data) { error in
                DispatchQueue.main.async {
                    self.isSaving = false
                    if let error = error {
                        self.errorMessage = "Errore salvataggio: \(error.localizedDescription)"
                    } else {
                        self.playlistName = ""
                    }
                }
            }
        } catch {
            isSaving = false
            errorMessage = "Errore nella codifica dei dati"
        }
    }
}
