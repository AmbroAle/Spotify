import SwiftUI

struct PlaylistDetailView: View {
    @State var playlist: Playlist
    @StateObject private var viewModel = PlaylistDetailViewModel()
    @State private var showAddTrackSheet = false
    @State private var searchText = ""
    @State private var selectedCarouselIndex = 0
    @State private var showEditAlert = false
    @State private var newPlaylistName = ""

    private let carouselTabs = ["Consigliati", "Piaciuti", "Recenti"]

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                if let url = viewModel.playlistCoverURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(12)
                } else {
                    Image("playlistcover")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                }

                Text(playlist.name)
                    .font(.largeTitle)
                    .bold()
                    .lineLimit(2)

                Spacer()

                Button {
                    newPlaylistName = playlist.name
                    showEditAlert = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.title)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            HStack {
                Spacer()
                Button {
                    showAddTrackSheet = true
                } label: {
                    Label("Aggiungi brano", systemImage: "plus")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding(.bottom, 4)

            if viewModel.isLoading {
                ProgressView()
                    .padding()
                Spacer()
            } else if viewModel.tracks.isEmpty {
                Text("Playlist vuota")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(viewModel.tracks) { track in
                        TrackRowView(track: track, albumCoverURL: track.cover_medium ?? "", viewModel: viewModel.albumDetailVM)
                            .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Playlist")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadTracks(for: playlist)
            viewModel.albumDetailVM.fetchLikedTracks()
        }
        .sheet(isPresented: $showAddTrackSheet) {
            AddTrackSheetView(
                searchText: $searchText,
                selectedIndex: $selectedCarouselIndex,
                carouselTabs: carouselTabs,
                playlistID: playlist.id
            )
        }
        .onChange(of: showAddTrackSheet) {
            if !showAddTrackSheet {
                Task {
                    await viewModel.loadTracks(for: playlist)
                }
            }
        }
        .alert("Modifica Nome Playlist", isPresented: $showEditAlert, actions: {
            TextField("Nuovo nome", text: $newPlaylistName)

            Button("Salva") {
                playlist.name = newPlaylistName
                Task {
                    await viewModel.updatePlaylistName(playlistID: playlist.id, newName: newPlaylistName)
                }
            }

            Button("Annulla", role: .cancel) {}
        })
    }
}
