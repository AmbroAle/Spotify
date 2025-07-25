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
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedGenre?.id == genre.id ? Color.green : Color.green.opacity(0.4))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
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
