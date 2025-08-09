import SwiftUI

struct GlobalChartView: View {
    @StateObject private var viewModel = ClassificationViewModel()
    @StateObject private var viewModelTrack = AlbumDetailViewModel()
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var playlistPlayerVM: PlaylistPlayerViewModel
    @State private var showingPlayer = false
    @State private var selectedIndex = 0

    var body: some View {
        VStack {
            List(Array(viewModel.deezerTracks.enumerated()), id: \.element.id) { index, track in
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: track.cover_medium ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(track.title)
                            .font(.headline)
                            .lineLimit(1)

                        HStack(spacing: 16) {
                            if !track.preview.isEmpty {
                                Button {
                                    if playlistPlayerVM.currentlyPlayingTrackID == track.id {
                                        playlistPlayerVM.togglePlayPause()
                                    } else {
                                        viewModelTrack.stopPlayback()
                                        playlistPlayerVM.setPlaylist(viewModel.deezerTracks)
                                        playlistPlayerVM.playTrack(at: index)
                                    }
                                } label: {
                                    Image(systemName: (playlistPlayerVM.currentlyPlayingTrackID == track.id && playlistPlayerVM.isPlaying)
                                          ? "pause.circle.fill"
                                          : "play.circle.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.green)
                                }
                                .buttonStyle(.plain)
                                .contentShape(Rectangle())
                            }

                            Button {
                                let wasLiked = viewModelTrack.likedTracks.contains(track.id)
                                viewModelTrack.toggleLike(for: track)
                                showLikeNotification(for: track, wasLiked: wasLiked)
                            } label: {
                                Image(systemName: viewModelTrack.likedTracks.contains(track.id) ? "heart.fill" : "heart")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 6)
                .contentShape(Rectangle())
                .onTapGesture {
                    playlistPlayerVM.setPlaylist(viewModel.deezerTracks)
                    playlistPlayerVM.setCurrentTrack(at: index)
                    selectedIndex = index
                    showingPlayer = true
                }
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Top Global")
        .task {
            await viewModel.fetchGlobalCharts()
            await viewModel.convertLastFMTracksToDeezerTracks()
            viewModelTrack.fetchLikedTracks()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModelTrack.stopPlayback()
                    playlistPlayerVM.stopPlayback()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
        }
        .fullScreenCover(isPresented: $showingPlayer) {
            MusicPlayerView(
                trackList: viewModel.deezerTracks,
                albumCoverURL: "spotify-top-50-global",
                albumDetailVM: viewModelTrack
            )
            .environmentObject(playlistPlayerVM)
        }
    }

    private func showLikeNotification(for track: TrackAlbumDetail, wasLiked: Bool) {
        let inAppEnabled = UserDefaults.standard.bool(forKey: "inAppNotificationsEnabled")
        guard inAppEnabled else { return }
        
        let message = wasLiked
            ? "\"\(track.title)\" rimosso dai preferiti"
            : "\"\(track.title)\" aggiunto ai preferiti"
        
        notificationManager.show(message: message)
    }
}
