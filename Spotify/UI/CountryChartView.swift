import SwiftUI

struct CountryChartView: View {
    let country: String
    @StateObject private var viewModel = ClassificationViewModel()
    @StateObject private var viewModelTrack = AlbumDetailViewModel()
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var playlistPlayerVM: PlaylistPlayerViewModel

    var body: some View {
        VStack {
            List {
                ForEach(Array(viewModel.deezerTracks.enumerated()), id: \.element.id) { index, track in
                    PlayableTrackRowDeezer(
                        track: track,
                        trackList: viewModel.deezerTracks,
                        currentIndex: index,
                        albumCoverURL: track.cover_medium ?? "",
                        albumDetailVM: viewModelTrack,
                    )
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)

            .listStyle(.plain)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Top \(country)")
        .task {
            await viewModel.fetchCountryCharts(country: country)
            await viewModel.convertLastFMTracksToDeezerTracks()
            viewModelTrack.fetchLikedTracks()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModelTrack.stopPlayback()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
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
struct PlayableTrackRowDeezer: View {
    let track: TrackAlbumDetail
    let trackList: [TrackAlbumDetail]
    let currentIndex: Int
    let albumCoverURL: String
    @ObservedObject var albumDetailVM: AlbumDetailViewModel
    @EnvironmentObject var playlistPlayerVM: PlaylistPlayerViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingPlayer = false

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: albumCoverURL)) { image in
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

                HStack(spacing: 12) {
                    if !track.preview.isEmpty {
                        Button {
                            if playlistPlayerVM.currentlyPlayingTrackID == track.id {
                                playlistPlayerVM.togglePlayPause()
                            } else {
                                albumDetailVM.stopPlayback()
                                playlistPlayerVM.setPlaylist(trackList) // assicura che sia settata
                                playlistPlayerVM.playTrack(at: currentIndex)
                            }
                        } label: {
                            Image(systemName: (playlistPlayerVM.currentlyPlayingTrackID == track.id && playlistPlayerVM.isPlaying)
                                  ? "pause.circle.fill"
                                  : "play.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.green)
                        }
                    }


                    Button {
                        let wasLiked = albumDetailVM.likedTracks.contains(track.id)
                        albumDetailVM.toggleLike(for: track)

                        showLikeNotification(for: track, wasLiked: wasLiked)
                    } label: {
                        Image(systemName: albumDetailVM.likedTracks.contains(track.id) ? "heart.fill" : "heart")
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
            playlistPlayerVM.setPlaylist(trackList)  // imposta la lista globale
            playlistPlayerVM.setCurrentTrack(at: currentIndex)
            showingPlayer = true
        }

        .fullScreenCover(isPresented: $showingPlayer) {
            MusicPlayerView(
                trackList: trackList,
                albumCoverURL: albumCoverURL,
                albumDetailVM: albumDetailVM
            ).environmentObject(playlistPlayerVM)
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
