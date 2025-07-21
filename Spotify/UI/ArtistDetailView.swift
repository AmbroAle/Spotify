import SwiftUI

struct ArtistDetailView: View {
    let artist: Artist
    @StateObject private var viewModel = ArtistAlbumViewModel()

    var body: some View {
        VStack {
            Text(artist.name)
                .font(.largeTitle)
                .padding()

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
            }
        }
    }
}

