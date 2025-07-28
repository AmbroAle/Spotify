import SwiftUI

//controllare perchè cambia leggeremente il colore quando cambi pagine con home
struct BottomMenuView: View {
    let barHeight: CGFloat = 60
    
    var body: some View {
        HStack(spacing: 40) {
            NavigationLink(destination: HomeView()) {
                menuItem(icon: "house.fill", label: "Home")
            }
            NavigationLink(destination: Text("Libreria")) {
                menuItem(icon: "books.vertical.fill", label: "La tua libreria")
            }
            NavigationLink(destination: Text("Crea")) {
                menuItem(icon: "plus.circle.fill", label: "Crea")
            }
        }
        .frame(height: barHeight)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }

    private func menuItem(icon: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            Text(label)
                .font(.caption2)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.primary)
    }
}
