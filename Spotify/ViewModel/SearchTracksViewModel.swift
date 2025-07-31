import Foundation
import FirebaseFirestore
import FirebaseAuth
import AVFoundation

@MainActor
class SearchTracksViewModel: ObservableObject {
    @Published var searchResults: [TrackAlbumDetail] = []
    @Published var currentlyPlayingTrackID: Int?
    @Published var addedTrackIDs: [Int] = []

    private var audioPlayer: AVPlayer?

    func searchTracks(with query: String) async {
        guard !query.isEmpty else {
            self.searchResults = []
            return
        }

        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.deezer.com/search?q=\(queryEncoded)"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(DeezerResponse<TrackAlbumDetail>.self, from: data)
            self.searchResults = response.data
        } catch {
            print("❌ Errore nella ricerca: \(error)")
        }
    }

    func fetchPlaylistTrackIDs(for playlistID: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("playlists")
                .document(playlistID)
                .getDocument()

            if let data = doc.data(), let ids = data["trackIDs"] as? [Int] {
                addedTrackIDs = ids
            }
        } catch {
            print("❌ Errore nel fetch trackIDs playlist: \(error)")
        }
    }

    func toggleTrackInPlaylist(_ track: TrackAlbumDetail, playlistID: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("playlists")
            .document(playlistID)

        if addedTrackIDs.contains(track.id) {
            ref.updateData([
                "trackIDs": FieldValue.arrayRemove([track.id])
            ])
            addedTrackIDs.removeAll { $0 == track.id }
        } else {
            ref.updateData([
                "trackIDs": FieldValue.arrayUnion([track.id])
            ])
            addedTrackIDs.append(track.id)
        }
    }

    func playOrPause(track: TrackAlbumDetail) {
        if currentlyPlayingTrackID == track.id {
            stopPlayback()
        } else {
            stopPlayback()
            guard let url = URL(string: track.preview) else { return }
            let item = AVPlayerItem(url: url)
            audioPlayer = AVPlayer(playerItem: item)
            audioPlayer?.play()
            currentlyPlayingTrackID = track.id

            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.currentlyPlayingTrackID = nil
                }
            }
        }
    }

    private func stopPlayback() {
        audioPlayer?.pause()
        audioPlayer = nil
        currentlyPlayingTrackID = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
