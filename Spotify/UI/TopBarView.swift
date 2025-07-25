import SwiftUI

struct TopBarView: View {
    @State private var selectedTab: String? = nil

    var body: some View {
        HStack(spacing: 14) {
            Image("UserIconDarkMode")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle())
                .padding(.leading, 20)

            tabButton(title: "Artisti", destination: ArtistView())
            tabButton(title: "Album", destination: AlbumView())
            tabButton(title: "Classifiche", destination: ClassificationView())

            Spacer()
        }
        .padding([.top, .horizontal])
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
        .onAppear {
                selectedTab = nil 
        }

    }

    // MARK: - Tab Button
    @ViewBuilder
    private func tabButton<T: View>(title: String, destination: T) -> some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(5)
                .frame(minWidth: 100, maxWidth: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1.0)
                )
                .background(
                    BlurView(style: .systemUltraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
        }
        .simultaneousGesture(TapGesture().onEnded {
            selectedTab = title
        })
    }
}
