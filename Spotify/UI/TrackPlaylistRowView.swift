import SwiftUI

struct TrackPlaylistRowView: View {
    let track: TrackAlbumDetail
    @ObservedObject var albumDetailVM: AlbumDetailViewModel
    @ObservedObject var playlistPlayerVM: PlaylistPlayerViewModel
    @EnvironmentObject var notificationManager: NotificationManager

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: track.cover_medium ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(track.title).font(.headline)
                Text(track.artistName).font(.caption)

                HStack(spacing: 12) {
                    if !track.preview.isEmpty {
                        Button(action: {
                            playlistPlayerVM.stopPlayback()
                            albumDetailVM.playOrPause(track: track)
                        }) {
                            Image(systemName: albumDetailVM.currentlyPlayingTrackID == track.id ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.green)
                        }
                    }

                    Button(action: {
                        let wasLiked = albumDetailVM.likedTracks.contains(track.id)
                        albumDetailVM.toggleLike(for: track)
                        showLikeNotification(for: track, wasLiked: wasLiked)

                    }) {
                        Image(systemName: albumDetailVM.likedTracks.contains(track.id) ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .background(albumDetailVM.currentlyPlayingTrackID == track.id ? Color.green.opacity(0.1) : Color.clear)
        .cornerRadius(10)
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
