import SwiftUI
import AVFoundation

struct AlbumDetailView: View {
    let album: DetailsAlbumArtist
    @StateObject private var viewModel = AlbumDetailViewModel()
    @State private var audioPlayer: AVPlayer?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(viewModel.tracks) { track in
                VStack(alignment: .leading, spacing: 6) {
                    Text(track.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    if !track.preview.isEmpty {
                        Button("Ascolta Anteprima") {
                            if let url = URL(string: track.preview) {
                                audioPlayer = AVPlayer(url: url)
                                audioPlayer?.play()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(
            AsyncImage(url: URL(string: album.cover_xl)) { image in
                image
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
                    .clipped()
                    .ignoresSafeArea()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
        )
        .navigationTitle(album.title)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
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
