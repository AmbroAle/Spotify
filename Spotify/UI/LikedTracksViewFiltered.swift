import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LikedTracksViewFiltered: View {
    let selectedPlaylistID: String
    @StateObject private var viewModel: LikedTracksViewModel

    init(selectedPlaylistID: String) {
        self.selectedPlaylistID = selectedPlaylistID
        _viewModel = StateObject(wrappedValue: LikedTracksViewModel(playlistID: selectedPlaylistID))
    }

    var body: some View {
        VStack {
            Text("Brani che ti piacciono")
                .font(.title2)
                .bold()
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .center)

            List {
                ForEach(viewModel.tracks) { track in
                    HStack {
                        AsyncImage(url: URL(string: track.cover_medium ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading) {
                            Text(track.title)
                                .font(.headline)
                            Text(track.artistName)
                                .font(.caption)
                        }

                        Spacer()

                        // Play/pause
                        Button {
                            viewModel.playOrPause(track: track)
                        } label: {
                            Image(systemName: viewModel.currentlyPlayingTrackID == track.id ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 8)

                        // Aggiungi/rimuovi dalla playlist
                        Button {
                            viewModel.toggleTrackInPlaylist(track)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(viewModel.addedTrackIDs.contains(track.id) ? .green : .gray)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            Task {
                await viewModel.fetchLikedTracks()
                await viewModel.fetchPlaylistTrackIDs()
            }
        }
    }
}
