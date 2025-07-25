import SwiftUI

struct AlbumView: View {
    @ObservedObject var viewModel: AlbumViewModel
    @State private var selectedGenre: Genre? = nil
    @Environment(\.dismiss) private var dismiss

    private var albumsToShow: [Album] {
        if !viewModel.searchQuery.isEmpty {
            return viewModel.searchResults
        } else if selectedGenre == nil {
            return viewModel.albumsPopularity
        } else {
            return viewModel.albums
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Cerca album...", text: $viewModel.searchQuery)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding([.horizontal, .top])
                    .onChange(of: viewModel.searchQuery) { oldValue, newValue in
                        Task {
                            if newValue.isEmpty {
                                viewModel.searchResults = []
                            } else {
                                selectedGenre = nil
                                await viewModel.searchAlbumsByName(newValue)
                            }
                        }
                    }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.genres) { genre in
                            Button(action: {
                                viewModel.searchQuery = ""

                                if selectedGenre?.id == genre.id {
                                    selectedGenre = nil
                                    Task {
                                        await viewModel.fetchNewReleases()
                                    }
                                } else {
                                    selectedGenre = genre
                                    Task {
                                        await viewModel.fetchAlbumsByGenre(genreID: genre.id)
                                    }
                                }
                            }) {
                                Text(genre.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .frame(minWidth: 100, maxWidth: 160)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1.0)
                                    )
                                    .background(selectedGenre?.id == genre.id ?  Color.green.opacity(0.8) : Color.white.opacity(0.05))
                                    .cornerRadius(10)
                                    .background(
                                        BlurView(style: .systemUltraThinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)

                List(albumsToShow) { album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        HStack {
                            AsyncImage(url: URL(string: album.cover_medium)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(album.title)
                                    .font(.headline)
                                
                                if let artistName = album.artist?.name {
                                    Text(artistName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Text("Data: \(album.release_date)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden()

        }
        .task {
            await viewModel.fetchGenres()
            await viewModel.fetchNewReleases()
        }
    }
}
