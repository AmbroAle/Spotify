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
                                // Mostra notifica
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

    @State private var showingPlayer = false

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: albumCoverURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 50)
            .cornerRadius(5)

            VStack(alignment: .leading) {
                Text(track.title ?? "Senza titolo")
                    .font(.headline)
                Text(track.artistName ?? "Sconosciuto")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                let isNewTrack = albumDetailVM.currentlyPlayingTrackID != track.id
                if isNewTrack {
                    albumDetailVM.saveRecentTrack(track)
                }
                albumDetailVM.playOrPause(track: track)
            }) {
                Image(systemName: albumDetailVM.currentlyPlayingTrackID == track.id ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.green)
            }
        }
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
}
