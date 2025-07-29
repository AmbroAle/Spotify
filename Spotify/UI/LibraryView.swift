import SwiftUI

struct LibraryView: View {
    @State private var showAddArtistSheet = false
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
                            Text("Brani con like")
                        } label: {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 24, height: 24)

                                Text("Brani che ti piacciono")
                                    .font(.headline)

                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    // Le tue playlist
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Le tue playlist")
                            .font(.headline)
                            .padding(.horizontal)

                        if viewModel.isLoading {
                            ProgressView().padding()
                        } else if viewModel.playlists.isEmpty {
                            Text("Nessuna playlist trovata.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(viewModel.playlists) { playlist in
                                NavigationLink {
                                    Text("Dettagli playlist: \(playlist.name)")
                                } label: {
                                    HStack {
                                        Image(systemName: "music.note.list")
                                            .foregroundColor(.blue)
                                            .frame(width: 24, height: 24)

                                        Text(playlist.name)
                                            .font(.body)

                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(.thinMaterial)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }

                    // Bottone per aggiungere artista
                    Button {
                        showAddArtistSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Aggiungi artista")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("")
            .task {
                viewModel.fetchPlaylists()
            }
            .sheet(isPresented: $showAddArtistSheet) {
                Text("Aggiungi artista")
                    .font(.title)
                    .padding()
            }
        }
    }
}

#Preview {
    LibraryView()
}
