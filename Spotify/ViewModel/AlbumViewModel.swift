import Foundation

class AlbumViewModel: ObservableObject {
    @Published var albumsPopularity: [Album] = []
    @Published var albums: [DetailsAlbumArtist] = []
    @Published var genres: [Genre] = []

    private let baseURL = "https://api.deezer.com"

    init() {
        Task {
            await fetchGenres()
        }
    }

    func fetchNewReleases() async {
        guard let url = URL(string: "https://api.deezer.com/editorial/0/releases") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DeezerResponse<Album>.self, from: data)
            await MainActor.run {
                self.albumsPopularity = decoded.data
            }
        } catch {
            print("❌ Errore nel fetch:", error.localizedDescription)
        }
    }
    
    func fetchGenres() async {
        guard let url = URL(string: "\(baseURL)/genre") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(DeezerResponse<Genre>.self, from: data)
            self.genres = result.data.filter { $0.id != 0 }
        } catch {
            print("Errore caricamento generi: \(error)")
        }
    }

    func fetchAlbumsByGenre(genreID: Int) async {
        guard let url = URL(string: "\(baseURL)/genre/\(genreID)/artists") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(DeezerResponse<Artist>.self, from: data)
            let artists = result.data.prefix(5)

            var loadedAlbums: [DetailsAlbumArtist] = []
            for artist in artists {
                guard let url = URL(string: "\(baseURL)/artist/\(artist.id)/albums") else { continue }
                let (data, _) = try await URLSession.shared.data(from: url)
                let albumResponse = try JSONDecoder().decode(DeezerResponse<DetailsAlbumArtist>.self, from: data)
                loadedAlbums += albumResponse.data
            }

            self.albums = loadedAlbums
        } catch {
            print("Errore caricamento album per genere: \(error)")
        }
    }
    
}
