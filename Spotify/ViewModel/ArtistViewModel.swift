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

    private let baseURL = "https://api.deezer.com"

    init() {
        Task {
            await fetchTopArtists()
        }
    }

    func fetchTopArtists() async {
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
}

struct TopArtistResponse: Codable {
    let data: [Artist]
}
