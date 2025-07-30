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
                // Barra di ricerca
                TextField("Cerca brani...", text: $searchText)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)

                // Swipe tra le categorie
                TabView(selection: $selectedIndex) {
                    RecommendedTracksView(selectedPlaylistID: playlistID)
                        .tag(0)
                    LikedTracksViewFiltered(searchText: $searchText)
                        .tag(1)
                    RecentTracksViewFiltered(searchText: $searchText)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
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
