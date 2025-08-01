import SwiftUI

struct LikedTracksView: View {
    @StateObject private var viewModel = AlbumDetailViewModel()
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.tracks.isEmpty {
                Text("Nessun brano con like trovato.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.tracks) { track in
                        TrackRowView(
                            track: track,
                            albumCoverURL: track.cover_medium ?? "",
                            viewModel: viewModel
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
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            NotificationBannerView()
                            .environmentObject(notificationManager)
        }
        .onAppear {
            viewModel.fetchFullLikedTracks()
        }
    }
}
