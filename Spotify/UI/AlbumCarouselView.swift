//
//  AlbumCarouselView.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 20/07/25.
//
import SwiftUI

struct AlbumCarouselView: View {
    @StateObject var viewModel = AlbumViewModel()

    // Divide gli album in gruppi da 3
    private var groupedAlbums: [[Album]] {
        stride(from: 0, to: viewModel.albumsPopularity.count, by: 3).map {
            Array(viewModel.albumsPopularity[$0..<min($0 + 3, viewModel.albumsPopularity.count)])
        }
    }

    var body: some View {
        VStack(alignment: .center) {
            Text("Album più popolari")
                .font(.title2)
                .bold()
                .padding(.leading)

            TabView {
                ForEach(groupedAlbums.indices, id: \.self) { index in
                    HStack(spacing: 16) {
                        ForEach(groupedAlbums[index], id: \.id) { album in
                            VStack {
                                AsyncImage(url: URL(string: album.cover_medium)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 100)
                                .cornerRadius(12)

                                Text(album.title)
                                    .font(.caption)
                                    .lineLimit(1)

                                Text(album.artist?.name ?? "")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 100)
                        }
                    }
                    .padding()
                }
            }
            .frame(height: 200)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .task {
                await viewModel.fetchNewReleases()
            }
        }
    }
}
