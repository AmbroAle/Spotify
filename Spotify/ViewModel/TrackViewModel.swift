//
//  TrackViewModel.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 20/07/25.
//

import Foundation

class TrackViewModel: ObservableObject {
    @Published var tracks: [Track] = []

    func fetchTopTracks() async {
        guard let url = URL(string: "https://api.deezer.com/chart/0/tracks") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DeezerTrackResponse.self, from: data)
            await MainActor.run {
                self.tracks = decoded.data
            }
        } catch {
            print("❌ Errore nel fetch tracce:", error.localizedDescription)
        }
    }
}
