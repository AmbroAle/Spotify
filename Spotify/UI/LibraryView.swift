import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel = PlaylistLibraryViewModel()
    @ObservedObject var profileViewModel: ProfileViewModel

    @State private var playlistToDelete: Playlist?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                
                HStack {
                    NavigationLink(destination: ProfileView(viewModel: profileViewModel)) {
                        profileImageView
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    Text("La tua libreria")
                        .font(.title2)
                        .bold()

                    Spacer()
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    NavigationLink {
                        LikedTracksView()
                    } label: {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.green)
                                .frame(width: 24, height: 24)

                            Text("Brani che ti piacciono")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                Text("Le tue playlist")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)

                if viewModel.isLoading {
                    ProgressView().padding()
                } else if viewModel.playlists.isEmpty {
                    Text("Nessuna playlist trovata.")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                } else {
                    List {
                        ForEach(viewModel.playlists) { playlist in
                            NavigationLink(destination: PlaylistDetailView(playlist: playlist)) {
                                HStack {
                                    Image(systemName: "music.note.list")
                                        .foregroundColor(.green)
                                        .frame(width: 24, height: 24)

                                    Text(playlist.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    playlistToDelete = playlist
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Elimina", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("")
            .task {
                viewModel.fetchPlaylists()
            }
            .alert("Elimina Playlist", isPresented: $showDeleteConfirmation, presenting: playlistToDelete) { playlist in
                Button("Elimina", role: .destructive) {
                    viewModel.deletePlaylist(playlist)
                }
                Button("Annulla", role: .cancel) {}
            } message: { playlist in
                Text("Sei sicuro di voler eliminare \"\(playlist.name)\"?")
            }
        }
    }

    @ViewBuilder
    private var profileImageView: some View {
        if let imageData = profileViewModel.pickedImageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if let url = profileViewModel.userImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Image("UserIconDarkMode").resizable().scaledToFill()
                @unknown default:
                    Image("UserIconDarkMode").resizable().scaledToFill()
                }
            }
        } else {
            Image("UserIconDarkMode")
                .resizable()
                .scaledToFill()
        }
    }
}
