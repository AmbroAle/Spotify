import Foundation
import AVFoundation

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

    func toggleLike(for trackID: Int) {
        if likedTracks.contains(trackID) {
            likedTracks.remove(trackID)
        } else {
            likedTracks.insert(trackID)
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
}
