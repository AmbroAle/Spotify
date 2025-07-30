import SwiftUI

struct LikedTracksViewFiltered: View {
    @Binding var searchText: String

    var body: some View {
        VStack {
            Text("Brani che ti piacciono")
            // Inserisci qui la logica per caricare e filtrare i brani piaciuti
            Spacer()
        }
    }
}
