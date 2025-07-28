import SwiftUI

struct GlobalChartView: View {
    @StateObject private var viewModel = ClassificationViewModel()
    @StateObject private var viewModelTrack = AlbumDetailViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            List(viewModel.deezerTracks) { track in
                HStack(spacing: 12) {
                    Image("spotify-top-50-global")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(track.title)
                            .font(.headline)
                            .lineLimit(1)

                        HStack(spacing: 16) {
                            if !track.preview.isEmpty {
                                Button(action: {
                                    viewModelTrack.playOrPause(track: track)
                                    if viewModelTrack.currentlyPlayingTrackID != track.id {
                                        viewModelTrack.saveRecentTrack(track)
                                    }
                                }) {
                                    Image(systemName: viewModelTrack.currentlyPlayingTrackID == track.id ? "pause.circle.fill" : "play.circle.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.green)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contentShape(Rectangle())
                            }

                            Button(action: {
                                viewModelTrack.toggleLike(for: track)
                            }) {
                                Image(systemName: viewModelTrack.likedTracks.contains(track.id) ? "heart.fill" : "heart")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contentShape(Rectangle())
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 6)
                .contentShape(Rectangle())
                .onTapGesture {}
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
}
