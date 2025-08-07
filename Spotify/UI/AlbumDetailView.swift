import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @StateObject private var viewModel = AlbumDetailViewModel()
    @StateObject private var playlistPlayerVM = PlaylistPlayerViewModel() // Aggiungi questo
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            // Contenuto principale
            List {
                ForEach(Array(viewModel.tracks.enumerated()), id: \.element.id) { index, track in
                    PlayableTrackRow(
                        track: track,
                        trackList: viewModel.tracks,
                        currentIndex: index,           // <-- qui
                        albumCoverURL: album.cover_medium,
                        albumDetailVM: viewModel,
                        playlistPlayerVM: playlistPlayerVM
                    )
                    .buttonStyle(.plain)
                }

            }
            .navigationTitle(album.title)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.stopPlayback()
                        playlistPlayerVM.stopPlayback() // Aggiungi questo
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchTracks(for: album.id)
                    viewModel.fetchLikedTracks()
                    // Configura la playlist nel player
                    playlistPlayerVM.setPlaylist(viewModel.tracks)
                }
            }

            NotificationBannerView()
                .environmentObject(notificationManager)
                .padding(.top, 0)
                .ignoresSafeArea(.all, edges: .top)
        }
    }
}

// ALTERNATIVA: Se preferisci mantenere TrackRowView esistente
// Puoi aggiungere un modificatore per aprire il player

extension TrackRowView {
    func withMusicPlayer(
        trackList: [TrackAlbumDetail],
        currentIndex: Int,
        playlistPlayerVM: PlaylistPlayerViewModel
    ) -> some View {
        self.overlay(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    // Apri il music player
                }
        )
    }
}
