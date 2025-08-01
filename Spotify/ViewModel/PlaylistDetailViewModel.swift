import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class PlaylistDetailViewModel: ObservableObject {
    @Published var tracks: [TrackAlbumDetail] = []
    @Published var isLoading = false

    var albumDetailVM = AlbumDetailViewModel()
    var playlistCoverURL: URL? {
        if let cover = tracks.first?.cover_medium, let url = URL(string: cover) {
            return url
        } else {
            return nil
        }
    }

    func loadTracks(for playlist: Playlist) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("playlists")
                .document(playlist.id)
                .getDocument()

            guard let data = doc.data(),
                  let trackIDs = data["trackIDs"] as? [Int],
                  !trackIDs.isEmpty else {
                self.tracks = []
                return
            }

            var fetchedTracks: [TrackAlbumDetail] = []

            for trackID in trackIDs {
                guard let url = URL(string: "https://api.deezer.com/track/\(trackID)") else { continue }

                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let track = try JSONDecoder().decode(TrackAlbumDetail.self, from: data)
                    fetchedTracks.append(track)
                } catch {
                    print("Errore fetch traccia \(trackID): \(error)")
                }
            }

            self.tracks = fetchedTracks
        } catch {
            print("❌ Errore nel recupero playlist da Firestore: \(error.localizedDescription)")
        }
    }
    
    func updatePlaylistName(playlistID: String, newName: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("playlists")
                .document(playlistID)
                .updateData(["name": newName])
            
            print("✅ Nome playlist aggiornato a '\(newName)'")
        } catch {
            print("❌ Errore aggiornamento nome playlist: \(error)")
        }
    }
    
    func removeTrack(_ trackID: Int, from playlistID: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let ref = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("playlists")
            .document(playlistID)

        do {
            try await ref.updateData([
                "trackIDs": FieldValue.arrayRemove([trackID])
            ])
            self.tracks.removeAll { $0.id == trackID }
        } catch {
            print("❌ Errore rimozione traccia \(trackID): \(error.localizedDescription)")
        }
    }
}
