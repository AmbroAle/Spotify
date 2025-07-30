import Foundation
import FirebaseAuth
import FirebaseFirestore
import AVFoundation

@MainActor
class RecentTracksViewModel: ObservableObject {
    @Published var recentTracks: [TrackAlbumDetail] = []
    @Published var currentlyPlayingTrackID: Int?
    @Published var addedTrackIDs: [Int] = []

    private var audioPlayer: AVPlayer?
    let selectedPlaylistID: String

    init(playlistID: String) {
        self.selectedPlaylistID = playlistID
    }

    func fetchRecentTracks() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ Nessun utente loggato")
            return
        }

        print("📥 UID: \(uid)")

        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid).collection("recentTracks")

        do {
            let snapshot = try await ref.getDocuments()

            let ids = snapshot.documents.map { $0.documentID }
            print("🔄 Trovati \(ids.count) ID recenti")

            var loadedTracks: [TrackAlbumDetail] = []

            for id in ids {
                guard let url = URL(string: "https://api.deezer.com/track/\(id)") else { continue }

                let (data, _) = try await URLSession.shared.data(from: url)
                let track = try JSONDecoder().decode(TrackAlbumDetail.self, from: data)
                loadedTracks.append(track)
            }

            self.recentTracks = loadedTracks
        } catch {
            print("❌ Errore nel caricamento delle tracce recenti: \(error.localizedDescription)")
        }
    }

    func fetchPlaylistTrackIDs() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("playlists")
                .document(selectedPlaylistID)
                .getDocument()

            if let data = doc.data(), let ids = data["trackIDs"] as? [Int] {
                addedTrackIDs = ids
            }
        } catch {
            print("❌ Errore nel fetch trackIDs playlist: \(error)")
        }
    }

    func toggleTrackInPlaylist(_ track: TrackAlbumDetail) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("playlists")
            .document(selectedPlaylistID)

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
