import SwiftUI

struct CountryChartView: View {
    let country: String
    @StateObject private var viewModel = ClassificationViewModel()
    @StateObject private var viewModelTrack = AlbumDetailViewModel()
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            List(viewModel.deezerTracks) { track in
                HStack(spacing: 12) {
                    Image("region_it_default")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(track.title)
                            .font(.headline)
                            .lineLimit(1)

                        HStack(spacing: 12) {
                            if !track.preview.isEmpty {
                                Button {
                                    viewModelTrack.playOrPause(track: track)
                                    if viewModelTrack.currentlyPlayingTrackID != track.id {
                                        viewModelTrack.saveRecentTrack(track)
                                    }
                                } label: {
                                    Image(systemName: viewModelTrack.currentlyPlayingTrackID == track.id ? "pause.circle.fill" : "play.circle.fill")
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
                                
                                // Mostra notifica
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
                }
                .padding(.vertical, 6)
                .contentShape(Rectangle())
                .onTapGesture {}
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
        }
        .overlay(alignment: .bottom) {
            NotificationBannerView()
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
