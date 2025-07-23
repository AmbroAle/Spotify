//
//  AlbumCarouselView.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 20/07/25.
//
import SwiftUI

struct AlbumCarouselView: View {
    @StateObject var viewModel = AlbumViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Album più popolari")
                .font(.title2)
                .bold()
                .padding(.leading)

            TabView {
                ForEach(viewModel.albumsPopularity) { album in
                    VStack {
                        AsyncImage(url: URL(string: album.cover_medium)) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 250, height: 250)
                        .cornerRadius(16)

                        Text(album.title)
                            .font(.headline)
                            .lineLimit(1)

                        Text(album.artist?.name ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    )
                    .padding(.horizontal, 16)
                }
            }
            .frame(height: 340)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .task {
                await viewModel.fetchNewReleases()
            }
        }
    }
}
