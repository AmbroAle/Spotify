import SwiftUI

struct ArtistDetailView: View {
    let artist: Artist
    @StateObject private var viewModel = ArtistAlbumViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
        
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: artist.picture_big)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250, alignment: .top)
                            .clipped()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                            .frame(height: 220)
                    }

                    Text(artist.name)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding()
                }

                if !viewModel.genres.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Generi")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 4)], spacing: 8) {
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
                    .padding()
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
            .navigationBarTitleDisplayMode(.inline)
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
