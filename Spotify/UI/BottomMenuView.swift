import SwiftUI

struct BottomMenuView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    let barHeight: CGFloat = 60

    var body: some View {
        HStack(spacing: 40) {
            Button {
                navigationManager.goTo(.home)
            } label: {
                menuItem(icon: "house.fill", label: "Home")
            }

            Button {
                navigationManager.goTo(.library)
            } label: {
                menuItem(icon: "books.vertical.fill", label: "La tua libreria")
            }

            Button {
                navigationManager.goTo(.create)
            } label: {
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
