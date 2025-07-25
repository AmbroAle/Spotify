// 👇 Incolla QUESTO PRIMA di `struct ArtistView`

import SwiftUI

struct ArtistView: View {
    @ObservedObject var viewModel: ArtistViewModel
    @State private var selectedGenre: Genre? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            TextField("Cerca artista...", text: $viewModel.searchQuery)
                .padding(10)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .padding([.horizontal, .top])
                .onChange(of: viewModel.searchQuery) {
                    Task {
                        await viewModel.searchArtists()
                    }
                }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.genres) { genre in
                        Button(action: {
                            if selectedGenre?.id == genre.id {
                                selectedGenre = nil
                                Task {
                                    await viewModel.fetchTopArtists()
                                }
                            } else {
                                selectedGenre = genre
                                Task {
                                    await viewModel.fetchArtistsByGenre(genreID: genre.id)
                                }
                            }
                        }) {
                            Text(genre.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(5)
                                .frame(minWidth: 90, maxWidth: 140)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1.0)
                                )
                                .background(
                                    (selectedGenre?.id == genre.id ? Color.green.opacity(0.8) : Color.white.opacity(0.05))
                                        .cornerRadius(10)
                                )
                                .background(
                                    BlurView(style: .systemUltraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                                .padding(.top)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)

            List(viewModel.artists) { artist in
                NavigationLink(destination: ArtistDetailView(artist: artist)) {
                    HStack {
                        AsyncImage(url: URL(string: artist.picture_medium)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        Text(artist.name)
                            .font(.headline)
                    }
                }
            }
            .refreshable {
                await viewModel.fetchTopArtists()
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await viewModel.fetchTopArtists()
        }
    }
}
