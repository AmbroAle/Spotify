import SwiftUI

struct ArtistDetailView: View {
    let artist: Artist
    @StateObject private var viewModel = ArtistAlbumViewModel()
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [GridItem(.adaptive(minimum: 50))]
    
    var body: some View {
        NavigationStack {
            List {
                // Header con immagine artista
                ArtistHeaderView(artist: artist)
                    .listRowInsets(EdgeInsets()) // rimuove padding extra

                // Se ci sono generi
                if !viewModel.genres.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Generi")
                            .font(.headline)
                        
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(viewModel.genres, id: \.self) { genre in
                                GenreTagView(genre: genre)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .listRowBackground(Color.clear)
                }

                // Album
                ForEach(viewModel.albums) { album in
                    AlbumRowView(album: album)
                        .listRowSeparator(.visible)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Album di \(artist.name)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
            .task {
                await viewModel.fetchAlbums(for: artist.id)
                await viewModel.fetchGenres(for: artist.name)
            }

            BottomMenuView() // se lo vuoi fisso sotto, meglio metterlo fuori dalla List
        }
    }
}

// Sotto-view di esempio
struct ArtistHeaderView: View {
    let artist: Artist
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: artist.picture_big)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipped()
            } placeholder: {
                Color.gray.opacity(0.2)
                    .frame(height: 250)
            }
            Text(artist.name)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .shadow(radius: 5)
                .padding()
        }
    }
}

struct GenreTagView: View {
    let genre: String
    
    var body: some View {
        let baseShape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        
        Text(genre)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .background(Color.green.opacity(0.30))
            .background(
                BlurView(style: .systemUltraThinMaterial)
                    .clipShape(baseShape)
            )
            .overlay(
                baseShape
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
    }
}

struct AlbumRowView: View {
    let album: Album
    
    var body: some View {
        NavigationLink(destination: AlbumDetailView(album: album)) {
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
                .padding(.leading, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
    }
}
