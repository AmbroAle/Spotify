//
//  TrackCarouselView.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 20/07/25.
//

import SwiftUI

struct TrackCarouselView: View {
    @StateObject private var viewModel = TrackViewModel()

    var body: some View {
        VStack(alignment: .center) {
            Text("Tracce più popolari")
                .font(.title)
                .bold()
                .padding(.top)
            TabView {
                ForEach(viewModel.tracks) { track in
                    VStack {
                        AsyncImage(url: URL(string: track.album.cover_medium)) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 250, height: 250)
                        .cornerRadius(12)

                        Text(track.title)
                            .font(.headline)
                            .lineLimit(1)

                        Text(track.artist.name)
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
            .frame(height: 360)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .task {
                await viewModel.fetchTopTracks()
            }
        }
    }
}
