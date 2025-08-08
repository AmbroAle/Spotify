import SwiftUI

struct CountryChartView: View {
    let country: String
    @StateObject private var viewModel = ClassificationViewModel()
    @StateObject private var viewModelTrack = AlbumDetailViewModel()
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playlistPlayerVM = PlaylistPlayerViewModel()

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
                        playlistPlayerVM: playlistPlayerVM
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
    @ObservedObject var playlistPlayerVM: PlaylistPlayerViewModel
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
                            let isNewTrack = albumDetailVM.currentlyPlayingTrackID != track.id
                            if isNewTrack {
                                albumDetailVM.saveRecentTrack(track)
                            }
                            albumDetailVM.playOrPause(track: track)
                        } label: {
                            Image(systemName: albumDetailVM.currentlyPlayingTrackID == track.id ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }

                    Button {
                        let wasLiked = albumDetailVM.likedTracks.contains(track.id)
                        albumDetailVM.toggleLike(for: track)

                        // Notifica
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
            playlistPlayerVM.setPlaylist(trackList)
            playlistPlayerVM.playTrack(at: currentIndex)
            showingPlayer = true
        }
        .fullScreenCover(isPresented: $showingPlayer) {
            MusicPlayerView(
                trackList: trackList,
                albumCoverURL: albumCoverURL,
                playlistPlayerVM: playlistPlayerVM,
                albumDetailVM: albumDetailVM
            )
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
