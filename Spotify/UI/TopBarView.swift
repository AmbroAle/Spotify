import SwiftUI

struct TopBarView: View {
    @State private var selectedTab: String = "Artisti"

    var body: some View {
        HStack(spacing: 24) {
            Image("UserIconDarkMode")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle())

            tabButton(title: "Artisti", destination: ArtistView())
            tabButton(title: "Album", destination: AlbumView())

            Spacer()
        }
        .padding([.top, .horizontal])
        .background(.ultraThinMaterial)
    }

    // MARK: - Tab Button
    @ViewBuilder
    private func tabButton<T: View>(title: String, destination: T) -> some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white) // testo sempre bianco
                .padding(10)
                .frame(maxWidth: 60)
                .background(
                    selectedTab == title ? Color.green.opacity(0.8) : Color.clear
                )
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1.2) // contorno visibile sempre
                )
        }
        .simultaneousGesture(TapGesture().onEnded {
            selectedTab = title
        })
    }
}
