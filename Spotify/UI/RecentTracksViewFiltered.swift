import SwiftUI

struct RecentTracksViewFiltered: View {
    @Binding var searchText: String

    var body: some View {
        VStack {
            Text("Brani ascoltati di recente")
            // Inserisci qui la logica per caricare e filtrare i brani recenti
            Spacer()
        }
    }
}
