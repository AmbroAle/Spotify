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
                guard let self = self else { return }
                Task { @MainActor in
                    self.currentlyPlayingTrackID = nil
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
    
    func saveRecentTrack(_ track: TrackAlbumDetail) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let trackRef = db.collection("users").document(userID).collection("recentTracks").document("\(track.id)")

        let trackData: [String: Any] = [
            "id": track.id,
            "title": track.title,
            "preview": track.preview,
            "timestamp": Timestamp(date: Date())
        ]

        trackRef.setData(trackData) { error in
            if let error = error {
                print("Errore salvataggio traccia recente: \(error.localizedDescription)")
            } else {
                print("Traccia recente salvata")
            }
        }
    }
    
    func fetchFullLikedTracks() {
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
                let ids = documents.compactMap { Int($0.documentID) }

                Task {
                    var fetchedTracks: [TrackAlbumDetail] = []

                    for id in ids {
                        let urlString = "https://api.deezer.com/track/\(id)"
                        guard let url = URL(string: urlString) else { continue }

                        do {
                            let (data, _) = try await URLSession.shared.data(from: url)
                            let track = try JSONDecoder().decode(TrackAlbumDetail.self, from: data)
                            fetchedTracks.append(track)
                        } catch {
                            print("Errore nel fetch per traccia \(id): \(error)")
                        }
                    }

                    DispatchQueue.main.async {
                        self.tracks = fetchedTracks
                        self.likedTracks = Set(ids)
                    }
                }
            }
    }
}
