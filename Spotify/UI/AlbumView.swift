import SwiftUI

struct AlbumView: View {
    @StateObject private var viewModel = AlbumViewModel()
    @State private var selectedGenre: Genre? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.genres) { genre in
                            Button(action: {
                                selectedGenre = genre
                                Task {
                                    await viewModel.fetchAlbumsByGenre(genreID: genre.id)
                                }
                            }) {
                                Text(genre.name)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedGenre?.id == genre.id ? Color.blue : Color.blue.opacity(0.4))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                
                if selectedGenre == nil {
                    List(viewModel.albumsPopularity) { album in
                        HStack {
                            AsyncImage(url: URL(string: album.cover_medium)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading) {
                                Text(album.title)
                                    .font(.headline)
                                Text(album.artist.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else {
                    List(viewModel.albums) { album in
                        NavigationLink(destination: AlbumDetailView(album: album)) {
                            HStack {
                                AsyncImage(url: URL(string: album.cover_medium)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading) {
                                    Text(album.title)
                                        .font(.headline)
                                    Text("Data: \(album.release_date)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
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
