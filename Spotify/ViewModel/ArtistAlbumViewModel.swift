import Foundation

@MainActor
class ArtistAlbumViewModel: ObservableObject {
    @Published var albums: [Album] = []

    func fetchAlbums(for artistID: Int) async {
        let urlString = "https://api.deezer.com/artist/\(artistID)/albums"
        guard let url = URL(string: urlString) else {
            print("URL non valido")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DeezerResponse.self, from: data)
            self.albums = decoded.data
        } catch {
            print("Errore nel caricamento degli album: \(error.localizedDescription)")
        }
    }
}
