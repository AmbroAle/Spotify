import Foundation
import FirebaseFirestore
import FirebaseAuth
import AVFoundation

@MainActor
class AddTrackSheetViewModel: ObservableObject {
    @Published var topTracks: [TrackAlbumDetail] = []
    @Published var likedTracks: [TrackAlbumDetail] = []
    @Published var currentlyPlayingTrackID: Int?
    @Published var addedTrackIDs: Set<Int> = []

    private var audioPlayer: AVPlayer?
    let selectedPlaylistID: String

        init(playlistID: String) {
            self.selectedPlaylistID = playlistID
        }

    func fetchTopTracks() async {
        let urlString = "https://api.deezer.com/chart/0/tracks"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(DeezerResponse<TrackAlbumDetail>.self, from: data)
            self.topTracks = response.data
        } catch {
            print("Errore nel fetch dei top tracks: \(error)")
        }
    }

    func playOrPause(track: TrackAlbumDetail) {
        if currentlyPlayingTrackID == track.id {
            stopPlayback()
        } else {
            stopPlayback()
            guard let url = URL(string: track.preview) else { return }
            let playerItem = AVPlayerItem(url: url)
            audioPlayer = AVPlayer(playerItem: playerItem)
            audioPlayer?.play()
            currentlyPlayingTrackID = track.id

            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: playerItem,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.currentlyPlayingTrackID = nil
                }
            }
        }
    }

    func stopPlayback() {
        audioPlayer?.pause()
        audioPlayer = nil
        currentlyPlayingTrackID = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    func toggleTrackInPlaylist(_ track: TrackAlbumDetail) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let playlistRef = db.collection("users").document(userID).collection("playlists").document(selectedPlaylistID)

        if addedTrackIDs.contains(track.id) {
            // Rimuovi dalla playlist
            playlistRef.updateData([
                "trackIDs": FieldValue.arrayRemove([track.id])
            ]) { error in
                if error == nil {
                    self.addedTrackIDs.remove(track.id)
                    print("🔴 Brano rimosso: \(track.title)")
                }
            }
        } else {
            // Aggiungi alla playlist
            playlistRef.updateData([
                "trackIDs": FieldValue.arrayUnion([track.id])
            ]) { error in
                if error == nil {
                    self.addedTrackIDs.insert(track.id)
                    print("🟢 Brano aggiunto: \(track.title)")
                }
            }
        }
    }
    
    func fetchPlaylistTrackIDs() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let playlistRef = db.collection("users").document(userID).collection("playlists").document(selectedPlaylistID)

        do {
            let snapshot = try await playlistRef.getDocument()
            if let data = snapshot.data(),
               let trackIDs = data["trackIDs"] as? [Int] {
                self.addedTrackIDs = Set(trackIDs)
            }
        } catch {
            print("Errore nel fetch dei trackIDs: \(error)")
        }
    }
    
}

