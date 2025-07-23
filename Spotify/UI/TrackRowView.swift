
import SwiftUI

struct TrackRowView: View {
    let track: TrackAlbumDetail
    let albumCoverURL: String
    @ObservedObject var viewModel: AlbumDetailViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: albumCoverURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(track.title)
                    .font(.headline)

                HStack(spacing: 12) {
                    if !track.preview.isEmpty {
                        Button(action: {
                            viewModel.playOrPause(track: track)
                            if viewModel.currentlyPlayingTrackID != track.id {
                                    viewModel.saveRecentTrack(track)
                                }
                        }) {
                            Image(systemName: viewModel.currentlyPlayingTrackID == track.id ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                        }
                    }

                    Button(action: {
                        viewModel.toggleLike(for: track)
                    }) {
                        Image(systemName: viewModel.likedTracks.contains(track.id) ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}
