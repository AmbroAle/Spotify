import Foundation
import AVFoundation

@MainActor
class PlaylistPlayerViewModel: ObservableObject {
    @Published var currentlyPlayingTrackID: Int?
    @Published var isPaused: Bool = false
    @Published var currentIndex: Int = 0  // Rendi questa proprietà pubblica

    private var audioPlayer: AVPlayer?
    private var tracks: [TrackAlbumDetail] = []
    
    // Proprietà pubbliche per l'interfaccia
    var currentTrack: TrackAlbumDetail? {
        guard currentIndex < tracks.count else { return nil }
        return tracks[currentIndex]
    }
    
    var hasNext: Bool { currentIndex < tracks.count - 1 }
    var hasPrevious: Bool { currentIndex > 0 }

    func setPlaylist(_ tracks: [TrackAlbumDetail]) {
        self.tracks = tracks
        // Non resettare l'indice se stiamo aggiornando la stessa playlist
    }

    func playPlaylist(startingAt index: Int = 0) {
        guard !tracks.isEmpty else { return }
        currentIndex = index
        playTrack(at: currentIndex)
    }

    func playTrack(at index: Int) {
        guard index >= 0 && index < tracks.count else {
            stopPlayback()
            return
        }
        
        currentIndex = index
        let track = tracks[index]
        
        guard let url = URL(string: track.preview), !track.preview.isEmpty else {
            // Se questa traccia non ha preview, prova la successiva
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
        guard hasNext else {
            stopPlayback()
            return
        }
        playTrack(at: currentIndex + 1)
    }
    
    func playPreviousTrack() {
        guard hasPrevious else { return }
        playTrack(at: currentIndex - 1)
    }

    func stopPlayback() {
        audioPlayer?.pause()
        audioPlayer = nil
        isPaused = false
        currentlyPlayingTrackID = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    // Metodo per trovare l'indice di una traccia specifica
    func findTrackIndex(_ trackID: Int) -> Int? {
        return tracks.firstIndex { $0.id == trackID }
    }
    
    // Metodo per impostare la traccia corrente senza avviare la riproduzione
    func setCurrentTrack(at index: Int) {
        guard index >= 0 && index < tracks.count else { return }
        currentIndex = index
    }
}
