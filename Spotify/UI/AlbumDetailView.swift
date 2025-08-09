import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @StateObject private var viewModel = AlbumDetailViewModel()
    @EnvironmentObject var playlistPlayerVM: PlaylistPlayerViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            List {
                ForEach(Array(viewModel.tracks.enumerated()), id: \.element.id) { index, track in
                    PlayableTrackRow(
                        track: track,
                        trackList: viewModel.tracks,
                        currentIndex: index,
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
                        playlistPlayerVM.stopPlayback()
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
                }
        )
    }
}
