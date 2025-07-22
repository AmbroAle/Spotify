import Foundation

@MainActor
class AlbumDetailViewModel: ObservableObject {
    @Published var tracks: [TrackAlbumDetail] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func fetchTracks(for albumID: Int) async {
        isLoading = true
        errorMessage = nil
        let urlString = "https://api.deezer.com/album/\(albumID)/tracks"
        guard let url = URL(string: urlString) else {
            errorMessage = "URL non valido"
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DeezerResponse<TrackAlbumDetail>.self, from: data)
            tracks = decoded.data
        } catch {
            errorMessage = "Errore nel caricamento delle tracce: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
