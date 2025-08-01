import SwiftUI

struct AddTrackSheetView: View {
    @Binding var searchText: String
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    let carouselTabs: [String]
    let playlistID: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextField("Cerca brani...", text: $searchText)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)

                if !searchText.isEmpty {
                    SearchTracksView(searchText: $searchText, selectedPlaylistID: playlistID)
                } else {
                    TabView(selection: $selectedIndex) {
                        RecommendedTracksView(selectedPlaylistID: playlistID)
                            .tag(0)
                        LikedTracksViewFiltered(selectedPlaylistID: playlistID)
                            .tag(1)
                        RecentTracksViewFiltered(selectedPlaylistID: playlistID)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                }
            }
            .navigationTitle("Aggiungi brano")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
    }
}
