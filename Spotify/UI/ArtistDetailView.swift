import SwiftUI

struct ArtistDetailView: View {
    let artist: Artist
    @StateObject private var viewModel = ArtistAlbumViewModel()

    var body: some View {
        NavigationStack() {
            VStack {
                Text(artist.name)
                    .font(.largeTitle)
                    .padding()
                
                if !viewModel.genres.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Generi")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                            ForEach(viewModel.genres, id: \.self) { genre in
                                Text(genre)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.black)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                List(viewModel.albums) { album in
                    HStack {
                        AsyncImage(url: URL(string: album.cover_medium)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading) {
                            Text(album.title)
                                .font(.headline)

                            Text("Uscita: \(album.release_date)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Album di \(artist.name)")
            .onAppear {
                Task {
                    await viewModel.fetchAlbums(for: artist.id)
                    await viewModel.fetchGenres(for: artist.name)
                }
            }
            BottomMenuView()
        }
        
    }
}

