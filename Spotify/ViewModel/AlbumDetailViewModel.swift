import Foundation
import AVFoundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class AlbumDetailViewModel: ObservableObject {
    @Published var tracks: [TrackAlbumDetail] = []
    @Published var likedTracks: Set<Int> = []
    @Published var currentlyPlayingTrackID: Int?

    private var audioPlayer: AVPlayer?

    func fetchTracks(for albumID: Int) async {
        let urlString = "https://api.deezer.com/album/\(albumID)/tracks"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DeezerResponse<TrackAlbumDetail>.self, from: data)
            self.tracks = decoded.data
        } catch {
            print("Errore nel caricamento delle tracce: \(error)")
        }
    }

    func toggleLike(for track: TrackAlbumDetail) {
        if likedTracks.contains(track.id) {
            likedTracks.remove(track.id)
            removeLikedTrack(track.id)
        } else {
            likedTracks.insert(track.id)
            saveLikedTrack(track)
        }
    }

    func playOrPause(track: TrackAlbumDetail) {
        if currentlyPlayingTrackID == track.id {
            audioPlayer?.pause()
            currentlyPlayingTrackID = nil
        } else {
            if let url = URL(string: track.preview) {
                audioPlayer = AVPlayer(url: url)
                audioPlayer?.play()
                currentlyPlayingTrackID = track.id
            }
        }
    }

    func stopPlayback() {
        audioPlayer?.pause()
        currentlyPlayingTrackID = nil
    }

    func saveLikedTrack(_ track: TrackAlbumDetail) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let trackData: [String: Any] = [
            "title": track.title,
            "preview": track.preview,
            "id": track.id
        ]

        db.collection("users")
            .document(userID)
            .collection("likedTracks")
            .document("\(track.id)")
            .setData(trackData) { error in
                if let error = error {
                    print("Errore salvataggio: \(error.localizedDescription)")
                } else {
                    print("Brano salvato con successo")
                }
            }
    }

    func removeLikedTrack(_ trackID: Int) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users")
            .document(userID)
            .collection("likedTracks")
            .document("\(trackID)")
            .delete { error in
                if let error = error {
                    print("Errore rimozione: \(error)")
                } else {
                    print("Brano rimosso")
                }
            }
    }

    func fetchLikedTracks() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users")
            .document(userID)
            .collection("likedTracks")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Errore caricamento liked tracks: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                let ids = documents.compactMap { doc in
                    Int(doc.documentID)
                }

                self.likedTracks = Set(ids)
            }
    }
}
