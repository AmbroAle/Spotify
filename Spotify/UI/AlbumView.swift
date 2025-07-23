import SwiftUI

struct AlbumView: View {
    @StateObject private var viewModel = AlbumViewModel()
    @State private var selectedGenre: Genre? = nil
    @Environment(\.dismiss) private var dismiss

    private var albumsToShow: [Album] {
        if selectedGenre == nil {
            return viewModel.albumsPopularity
        } else {
            return viewModel.albums
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.genres) { genre in
                            Button(action: {
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
            .navigationTitle("Album")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }

            BottomMenuView()
        }
        .task {
            await viewModel.fetchGenres()
            await viewModel.fetchNewReleases()
        }
    }
}
