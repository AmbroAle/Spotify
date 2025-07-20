//
//  AlbumViewModel.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 20/07/25.
//
import Foundation

class AlbumViewModel: ObservableObject {
    @Published var albums: [Album] = []

    func fetchNewReleases() async {
        guard let url = URL(string: "https://api.deezer.com/editorial/0/releases") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DeezerResponse.self, from: data)
            await MainActor.run {
                self.albums = decoded.data
            }
        } catch {
            print("❌ Errore nel fetch:", error.localizedDescription)
        }
    }
}
