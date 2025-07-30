import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel = PlaylistLibraryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Intestazione
                    HStack {
                        Image("UserIconDarkMode")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                        Text("La tua libreria")
                            .font(.title2)
                            .bold()

                        Spacer()
                    }
                    .padding(.horizontal)

                    // Liked Tracks
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
                                    .foregroundColor(.primary) // <-- niente colore blu

                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain) // <-- evita stile blu del link
                    }
                    .padding(.horizontal)

                    // Le tue playlist (centrate)
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
                                            .foregroundColor(.primary) // <-- no link blu

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
}
