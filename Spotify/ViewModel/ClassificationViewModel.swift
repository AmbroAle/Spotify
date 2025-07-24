import Foundation

@MainActor
class ClassificationViewModel: ObservableObject {
    @Published var tracks: [TrackLastFM] = []
    @Published var deezerTracks: [TrackAlbumDetail] = []

    private let apiKey = "199f1091fa2d652feb4cfaabd22b85c8"
    private let baseURL = "https://ws.audioscrobbler.com/2.0/"

    func fetchGlobalCharts() async {
        guard let url = URL(string: "\(baseURL)?method=chart.gettoptracks&api_key=\(apiKey)&format=json&limit=50") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(TopTracksResponse.self, from: data)
            self.tracks = decoded.tracks.track
        } catch {
            print("❌ Errore fetch global: \(error.localizedDescription)")
        }
    }

    func fetchCountryCharts(country: String) async {
        guard let encodedCountry = country.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?method=geo.gettoptracks&country=\(encodedCountry)&api_key=\(apiKey)&format=json&limit=50") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(TopTracksResponse.self, from: data)
            self.tracks = decoded.tracks.track
        } catch {
            print("❌ Errore fetch country: \(error.localizedDescription)")
        }
    }
    
    func convertLastFMTracksToDeezerTracks() async {
        var fetchedTracks: [TrackAlbumDetail] = []

        await withTaskGroup(of: TrackAlbumDetail?.self) { group in
            for track in tracks.prefix(20) { // Limita a 20 per performance
                group.addTask {
                    return await self.searchDeezerTrack(title: track.nameTrack, artist: track.nameArtist)
                }
            }

            for await result in group {
                if let track = result {
                    fetchedTracks.append(track)
                }
            }
        }

        self.deezerTracks = fetchedTracks
    }
    
    func searchDeezerTrack(title: String, artist: String) async -> TrackAlbumDetail? {
        let query = "\(title) \(artist)"
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.deezer.com/search?q=\(encoded)") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DeezerResponse<TrackAlbumDetail>.self, from: data)
            return decoded.data.first // Prendiamo solo la prima traccia trovata
        } catch {
            print("Errore nella ricerca Deezer per '\(query)': \(error.localizedDescription)")
            return nil
        }
    }
}
