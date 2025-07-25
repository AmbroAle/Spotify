import Foundation

@MainActor
class ArtistAlbumViewModel: ObservableObject {
    @Published var albums: [Album] = []
    @Published var genres: [String] = []

    func fetchAlbums(for artistID: Int) async {
        let urlString = "https://api.deezer.com/artist/\(artistID)/albums"
        guard let url = URL(string: urlString) else {
            print("URL non valido")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DeezerResponse<Album>.self, from: data)
            
            let groupedByTitle = Dictionary(grouping: decoded.data, by: \.title)
            let uniqueAlbums = groupedByTitle.compactMap { $0.value.max(by: { $0.release_date < $1.release_date }) }
            
            self.albums = uniqueAlbums.sorted { $0.release_date > $1.release_date }
            
        } catch {
            print("Errore nel caricamento degli album: \(error.localizedDescription)")
        }
    }
    
    func fetchGenres(for artistName: String) async {
        let encodedName = artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? artistName
        let urlString = "https://ws.audioscrobbler.com/2.0/?method=artist.getTopTags&artist=\(encodedName)&api_key=199f1091fa2d652feb4cfaabd22b85c8&format=json"
        
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(TopTagsResponse.self, from: data)
            let knownGenres = ["rock", "pop", "hip hop", "rap", "jazz", "electronic", "reggae", "metal", "indie", "classical", "techno", "funk", "soul"]

            let filtered = decoded.toptags.tag
                .map { $0.name.lowercased() }
                .filter { knownGenres.contains($0) }
                .prefix(5)
                .map { $0.capitalized }

            self.genres = Array(filtered)
        } catch {
            print("Errore nel caricamento dei generi: \(error)")
        }
    }
    
}
