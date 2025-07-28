import SwiftUI

struct ArtistDetailView: View {
    let artist: Artist
    @StateObject private var viewModel = ArtistAlbumViewModel()
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [GridItem(.adaptive(minimum: 50))]

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ArtistHeaderView(artist: artist)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

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
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }

                    ForEach(viewModel.albums) { album in
                        NavigationLink(destination: AlbumDetailView(album: album)) {
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: album.cover_medium)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(album.title)
                                        .font(.headline)
                                        .lineLimit(1)

                                    Text("Uscita: \(album.release_date)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                }
                .listStyle(.plain)
                
                .padding(.horizontal, 0)
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

                BottomMenuView()
            }
            .task {
                await viewModel.fetchAlbums(for: artist.id)
                await viewModel.fetchGenres(for: artist.name)
            }
        }
    }
}

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
