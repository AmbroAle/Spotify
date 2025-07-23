import Foundation

@MainActor
class AlbumViewModel: ObservableObject {
    @Published var albumsPopularity: [Album] = []
    @Published var albums: [Album] = []
    @Published var genres: [Genre] = []
    @Published var searchQuery: String = ""
    @Published var searchResults: [Album] = []

    private let baseURL = "https://api.deezer.com"

    init() {
        Task {
            await fetchGenres()
            await fetchNewReleases()
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

            var loadedAlbums: [Album] = []

            for artist in artists {
                guard let url = URL(string: "\(baseURL)/artist/\(artist.id)/albums") else { continue }
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(DeezerResponse<Album>.self, from: data)

                for var album in response.data {
                    album.artist = AlbumArtist(name: artist.name)
                    loadedAlbums.append(album)
                    if loadedAlbums.count >= 50 { break }
                }

                if loadedAlbums.count >= 50 { break }
            }

            let groupedByTitle = Dictionary(grouping: loadedAlbums, by: { $0.title })
            let uniqueAlbums = groupedByTitle.compactMap { $0.value.max(by: { $0.release_date < $1.release_date }) }

            self.albums = uniqueAlbums.sorted(by: { $0.release_date > $1.release_date }).prefix(20).map { $0 }

        } catch {
            print("Errore caricamento album per genere: \(error)")
        }
    }
    
    func searchAlbumsByName(_ query: String) async {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.deezer.com/search/album?q=\(encoded)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DeezerResponse<SearchedAlbum>.self, from: data)

            // Mappa in `Album` compatibili
            self.searchResults = decoded.data.map {
                Album(
                    id: $0.id,
                    title: $0.title,
                    cover_medium: $0.cover_medium,
                    release_date: "N/D", 
                    artist: AlbumArtist(name: $0.artist.name)
                )
            }
        } catch {
            print("Errore ricerca album: \(error.localizedDescription)")
        }
    }
}
