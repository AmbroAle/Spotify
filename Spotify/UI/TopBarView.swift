import SwiftUI

struct TopBarView: View {
    @State private var selectedTab: String = "Artisti"

    var body: some View {
        HStack(spacing: 20) {
            Image("UserIconDarkMode")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle())

            tabButton(title: "Artisti", destination: ArtistView())
            tabButton(title: "Album", destination: AlbumView())
            tabButton(title: "Classifiche", destination: EmptyView())

            Spacer()
        }
        .padding([.top, .horizontal])
        .padding(.bottom, 8)
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
                .frame(maxWidth: 120)
                .frame(minWidth: 90)
                .background(
                    selectedTab == title ? Color.green.opacity(0.8) : Color.clear
                )
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1.2) // contorno visibile sempre
                )
        }
        .simultaneousGesture(TapGesture().onEnded {
            selectedTab = title
        })
    }
}
