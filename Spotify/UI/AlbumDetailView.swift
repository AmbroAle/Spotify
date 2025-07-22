import SwiftUI

struct AlbumDetailView: View {
    let album: DetailsAlbumArtist
    @StateObject private var viewModel = AlbumDetailViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(viewModel.tracks) { track in
                TrackRowView(track: track, albumCoverURL: album.cover_medium, viewModel: viewModel)
                    .buttonStyle(.plain)
            }
        }
        .navigationTitle(album.title)
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
        .onAppear {
            Task {
                await viewModel.fetchTracks(for: album.id)
            }
        }

        BottomMenuView()
    }
}
