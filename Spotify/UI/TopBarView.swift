import SwiftUI

struct TopBarView: View {
    @Binding var selectedTab: String
    
    var body: some View {
        HStack(spacing: 14) {
            NavigationLink(destination: ProfileView()) {
                Image("UserIconDarkMode")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.leading, 6)
            }
            .buttonStyle(PlainButtonStyle())

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    tabButton(title: "Tutti")
                    tabButton(title: "Artisti")
                    tabButton(title: "Album")
                    tabButton(title: "Classifiche")
                }
            }
            .padding(.bottom, 5)
            Spacer()
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
        .background(.ultraThinMaterial)
    }
    
    private func tabButton(title: String) -> some View {
        LiquidGlassButton(
            title: title,
            action: {
                selectedTab = title
            },
            gradientColors: selectedTab == title
                ? [
                    Color.green.opacity(0.4),
                    Color.green.opacity(0.6)
                  ]
                : [
                    Color.white.opacity(0.25),
                    Color.white.opacity(0.05)
                  ],
            font: .system(size: 14, weight: .medium),
            minwidth: 90,
            maxwidth: 120
        )
    }

    
}
