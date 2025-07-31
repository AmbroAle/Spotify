import Foundation
import AVFoundation

@MainActor
class PlaylistPlayerViewModel: ObservableObject {
    @Published var currentlyPlayingTrackID: Int?
    @Published var isPaused: Bool = false

    private var audioPlayer: AVPlayer?
    private var tracks: [TrackAlbumDetail] = []
    private(set) var currentIndex: Int = 0

    func setPlaylist(_ tracks: [TrackAlbumDetail]) {
        self.tracks = tracks
        self.currentIndex = 0
    }

    func playPlaylist() {
        guard !tracks.isEmpty else { return }
        playTrack(at: currentIndex)
    }

    func playTrack(at index: Int) {
        guard index < tracks.count else {
            stopPlayback()
            return
        }

        let track = tracks[index]
        guard let url = URL(string: track.preview) else {
            playNextTrack()
            return
        }

        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer?.play()
        isPaused = false
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

    func togglePlayPause() {
        guard let player = audioPlayer else { return }

        if isPaused {
            player.play()
        } else {
            player.pause()
        }

        isPaused.toggle()
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
        isPaused = false
        currentlyPlayingTrackID = nil
        currentIndex = 0
        NotificationCenter.default.removeObserver(self)
    }
}
