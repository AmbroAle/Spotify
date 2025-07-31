import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel = PlaylistLibraryViewModel()
    @ObservedObject var profileViewModel: ProfileViewModel
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    HStack {
                        profileImageView
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

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

                    VStack(spacing: 12) {
                        Text("Le tue playlist")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)

                        if viewModel.isLoading {
                            ProgressView().padding()
                        } else if viewModel.playlists.isEmpty {
                            Text("Nessuna playlist trovata.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(viewModel.playlists) { playlist in
                                NavigationLink {
                                    PlaylistDetailView(playlist: playlist)
                                } label: {
                                    HStack {
                                        Image(systemName: "music.note.list")
                                            .foregroundColor(.green)
                                            .frame(width: 24, height: 24)

                                        Text(playlist.name)
                                            .font(.body)
                                            .foregroundColor(.primary)

                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(.thinMaterial)
                                    .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("")
            .task {
                viewModel.fetchPlaylists()
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
