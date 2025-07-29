import SwiftUI

struct LikedTracksView: View {
    @StateObject private var viewModel = AlbumDetailViewModel()
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
                            albumCoverURL: "", // Inserisci URL se disponibile
                            viewModel: viewModel
                        )
                        .buttonStyle(.plain)
                    }
                }
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
        }
        .onAppear {
            viewModel.fetchFullLikedTracks()
        }
    }
}
