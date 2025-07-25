//
//  ArtistViewModel.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 21/07/25.
//

import Foundation

@MainActor
class ArtistViewModel: ObservableObject {
    @Published var artists: [Artist] = []
    @Published var searchQuery: String = ""
    @Published var genres: [Genre] = []

    private let baseURL = "https://api.deezer.com"

    init() {
        Task {
            await fetchTopArtists()
            await fetchGenres()
        }
    }

    func fetchTopArtists() async {
        print("fetchTopArtists called")
        guard let url = URL(string: "\(baseURL)/chart/0/artists") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let result = try? JSONDecoder().decode(TopArtistResponse.self, from: data) {
                self.artists = Array(result.data.prefix(10))
            }
        } catch {
            print("Errore nel fetch dei top artisti: \(error)")
        }
    }

    func searchArtists() async {
        guard !searchQuery.isEmpty else {
            await fetchTopArtists()
            return
        }

        let query = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)/search/artist?q=\(query)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let result = try? JSONDecoder().decode(TopArtistResponse.self, from: data) {
                self.artists = result.data
            }
        } catch {
            print("Errore nella ricerca: \(error)")
        }
    }
    
    func fetchGenres() async {
        guard let url = URL(string: "\(baseURL)/genre") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let result = try? JSONDecoder().decode(DeezerResponse<Genre>.self, from: data) {
                self.genres = result.data.filter { $0.id != 0 }
            }
        } catch {
            print("Errore nel fetch dei generi: \(error)")
        }
    }
    
    func fetchArtistsByGenre(genreID: Int) async {
        guard let url = URL(string: "\(baseURL)/genre/\(genreID)/artists") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let result = try? JSONDecoder().decode(TopArtistResponse.self, from: data) {
                self.artists = result.data
            }
        } catch {
            print("Errore nel fetch artisti per genere: \(error)")
        }
    }
}

struct TopArtistResponse: Codable {
    let data: [Artist]
}
