import Foundation
import FirebaseFirestore
import FirebaseAuth
import AVFoundation

@MainActor
class LikedTracksViewModel: ObservableObject {
    @Published var tracks: [TrackAlbumDetail] = []
    @Published var addedTrackIDs: Set<Int> = []
    @Published var currentlyPlayingTrackID: Int?

    private var audioPlayer: AVPlayer?
    private let selectedPlaylistID: String

    init(playlistID: String) {
        self.selectedPlaylistID = playlistID
    }

    func fetchLikedTracks() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let snapshot = try? await db.collection("users").document(userID).collection("likedTracks").getDocuments()

        guard let documents = snapshot?.documents else { return }

        var loaded: [TrackAlbumDetail] = []
        for doc in documents {
            if let id = Int(doc.documentID) {
                do {
                    let url = URL(string: "https://api.deezer.com/track/\(id)")!
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let track = try JSONDecoder().decode(TrackAlbumDetail.self, from: data)
                    loaded.append(track)
                } catch {
                    print("Errore fetch traccia \(id): \(error)")
                }
            }
        }
        self.tracks = loaded
    }

    func fetchPlaylistTrackIDs() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        do {
            let snapshot = try await db.collection("users")
                .document(userID)
                .collection("playlists")
                .document(selectedPlaylistID)
                .getDocument()

            if let data = snapshot.data(),
               let ids = data["trackIDs"] as? [Int] {
                self.addedTrackIDs = Set(ids)
            }
        } catch {
            print("Errore fetch playlist trackIDs: \(error)")
        }
    }

    func toggleTrackInPlaylist(_ track: TrackAlbumDetail) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let ref = db.collection("users")
            .document(userID)
            .collection("playlists")
            .document(selectedPlaylistID)

        if addedTrackIDs.contains(track.id) {
            ref.updateData([
                "trackIDs": FieldValue.arrayRemove([track.id])
            ]) { error in
                if error == nil {
                    self.addedTrackIDs.remove(track.id)
                }
            }
        } else {
            ref.updateData([
                "trackIDs": FieldValue.arrayUnion([track.id])
            ]) { error in
                if error == nil {
                    self.addedTrackIDs.insert(track.id)
                }
            }
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

    func stopPlayback() {
        audioPlayer?.pause()
        audioPlayer = nil
        currentlyPlayingTrackID = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
