import Foundation
import FirebaseAuth

@MainActor
class PlaylistDetailViewModel: ObservableObject {
    @Published var tracks: [TrackAlbumDetail] = []
    @Published var isLoading = false

    var albumDetailVM = AlbumDetailViewModel() // riuso ViewModel per gestione play/like

    func loadTracks(for playlist: Playlist) async {
        guard !playlist.trackIDs.isEmpty else {
            tracks = []
            return
        }

        isLoading = true
        var fetchedTracks: [TrackAlbumDetail] = []

        for trackID in playlist.trackIDs {
            let urlString = "https://api.deezer.com/track/\(trackID)"
            guard let url = URL(string: urlString) else { continue }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let track = try JSONDecoder().decode(TrackAlbumDetail.self, from: data)
                fetchedTracks.append(track)
            } catch {
                print("Errore fetch traccia \(trackID): \(error)")
            }
        }

        tracks = fetchedTracks
        isLoading = false
    }
}
