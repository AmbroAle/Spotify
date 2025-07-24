import Foundation

@MainActor
class ClassificationViewModel: ObservableObject {
    @Published var tracks: [TrackLastFM] = []

    private let apiKey = "199f1091fa2d652feb4cfaabd22b85c8"
    private let baseURL = "https://ws.audioscrobbler.com/2.0/"

    func fetchGlobalCharts() async {
        guard let url = URL(string: "\(baseURL)?method=chart.gettoptracks&api_key=\(apiKey)&format=json&limit=20") else { return }

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
              let url = URL(string: "\(baseURL)?method=geo.gettoptracks&country=\(encodedCountry)&api_key=\(apiKey)&format=json&limit=20") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(TopTracksResponse.self, from: data)
            self.tracks = decoded.tracks.track
        } catch {
            print("❌ Errore fetch country: \(error.localizedDescription)")
        }
    }
}
