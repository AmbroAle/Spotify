import SwiftUI

struct PlaylistDetailView: View {
    @State var playlist: Playlist
    @StateObject private var viewModel = PlaylistDetailViewModel()
    @State private var showAddTrackSheet = false
    @State private var searchText = ""
    @State private var selectedCarouselIndex = 0
    @State private var showEditAlert = false
    @State private var newPlaylistName = ""
    @StateObject private var playerVM = PlaylistPlayerViewModel()

    @State private var trackToDelete: TrackAlbumDetail?
    @State private var showDeleteConfirmation = false

    private let carouselTabs = ["Consigliati", "Piaciuti", "Recenti"]

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                if let url = viewModel.playlistCoverURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
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

                VStack(alignment: .leading, spacing: 8) {
                    Text(playlist.name)
                        .font(.title)
                        .bold()
                        .lineLimit(2)

                    Button(action: {
                        playerVM.setPlaylist(viewModel.tracks)
                        playerVM.playPlaylist()
                    }) {
                        Label("Play Playlist", systemImage: "music.note.list")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                Button {
                    newPlaylistName = playlist.name
                    showEditAlert = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.title2)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top)
            
            HStack {
                Button {
                    showAddTrackSheet = true
                } label: {
                    Label("Aggiungi brano", systemImage: "plus")
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)

            Divider()

            if viewModel.isLoading {
                ProgressView().padding()
                Spacer()
            } else if viewModel.tracks.isEmpty {
                Text("Playlist vuota")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(viewModel.tracks) { track in
                        TrackRowView(track: track, albumCoverURL: track.cover_medium ?? "", viewModel: viewModel.albumDetailVM)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    trackToDelete = track
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Elimina", systemImage: "trash")
                                }
                            }
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
        .alert("Modifica Nome Playlist", isPresented: $showEditAlert) {
            TextField("Nuovo nome", text: $newPlaylistName)
            Button("Salva") {
                playlist.name = newPlaylistName
                Task {
                    await viewModel.updatePlaylistName(playlistID: playlist.id, newName: newPlaylistName)
                }
            }
            Button("Annulla", role: .cancel) {}
        }
        .alert("Eliminare questa traccia?", isPresented: $showDeleteConfirmation) {
            Button("Elimina", role: .destructive) {
                if let track = trackToDelete {
                    Task {
                        await viewModel.removeTrack(track.id, from: playlist.id)
                    }
                }
            }
            Button("Annulla", role: .cancel) {
                trackToDelete = nil
            }
        } message: {
            if let track = trackToDelete {
                Text("“\(track.title)” sarà rimossa dalla playlist.")
            }
        }
    }
}
