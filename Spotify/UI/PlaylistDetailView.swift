import SwiftUI

struct PlaylistDetailView: View {
    let playlist: Playlist
    @StateObject private var viewModel = PlaylistDetailViewModel()
    @State private var showAddTrackSheet = false
    @State private var searchText = ""
    @State private var selectedCarouselIndex = 0
    
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
                    showAddTrackSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

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
                carouselTabs: carouselTabs, playlistID: playlist.id
            )
        }
        .onChange(of: showAddTrackSheet) {
            if !showAddTrackSheet {
                Task {
                    await viewModel.loadTracks(for: playlist)
                }
            }
        }
    }
}
