import Foundation
import AVFoundation

@MainActor
class PlaylistPlayerViewModel: ObservableObject {
    @Published var currentlyPlayingTrackID: Int?

    private var audioPlayer: AVPlayer?
    private var tracks: [TrackAlbumDetail] = []
    private var currentIndex: Int = 0

    func setPlaylist(_ tracks: [TrackAlbumDetail]) {
        self.tracks = tracks
        self.currentIndex = 0
    }

    func playPlaylist() {
        guard !tracks.isEmpty else { return }
        playTrack(at: currentIndex)
    }

    private func playTrack(at index: Int) {
        guard index < tracks.count else {
            stopPlayback()
            return
        }

        let track = tracks[index]
        guard let url = URL(string: track.preview) else {
            playNextTrack() // se url non valida passa avanti
            return
        }

        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer?.play()
        currentlyPlayingTrackID = track.id

        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.playNextTrack()
            }
        }
    }

    func playNextTrack() {
        currentIndex += 1
        if currentIndex < tracks.count {
            playTrack(at: currentIndex)
        } else {
            stopPlayback()
        }
    }

    func stopPlayback() {
        audioPlayer?.pause()
        audioPlayer = nil
        currentlyPlayingTrackID = nil
        NotificationCenter.default.removeObserver(self)
        currentIndex = 0
    }
}
