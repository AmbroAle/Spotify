import SwiftUI

struct RecentTracksViewFiltered: View {
    let selectedPlaylistID: String
    @StateObject private var viewModel: RecentTracksViewModel

    init(selectedPlaylistID: String) {
        self.selectedPlaylistID = selectedPlaylistID
        _viewModel = StateObject(wrappedValue: RecentTracksViewModel(playlistID: selectedPlaylistID))
    }

    var body: some View {
        VStack {
            Text("Ascoltati di recente")
                .font(.title2)
                .bold()
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .center)

            List {
                ForEach(viewModel.recentTracks) { track in
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
                                .foregroundColor(.gray)
                        }

                        Spacer()

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
                await viewModel.fetchRecentTracks()
                await viewModel.fetchPlaylistTrackIDs()
            }
        }
    }
}
