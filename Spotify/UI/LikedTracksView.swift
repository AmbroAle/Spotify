import SwiftUI

struct LikedTracksView: View {
    @StateObject private var viewModel = AlbumDetailViewModel()
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var playlistPlayerVM: PlaylistPlayerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.tracks.isEmpty {
                Text("Nessun brano con like trovato.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(Array(viewModel.tracks.enumerated()), id: \.element.id) { index, track in
                        PlayableTrackRow(
                            track: track,
                            trackList: viewModel.tracks,
                            currentIndex: index,
                            albumCoverURL: track.cover_medium ?? "",
                            albumDetailVM: viewModel
                        )
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Brani che ti piacciono")
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
            }
        }
        .onAppear {
            viewModel.fetchFullLikedTracks()
        }
    }
}
