import SwiftUI

struct TopBarView: View {
    @Binding var selectedTab: String

    var body: some View {
        HStack(spacing: 14) {
            Image("UserIconDarkMode")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .padding(.leading, 6)
            
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
        Button(action: {
            selectedTab = title
        }) {
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
                    (selectedTab == title ? Color.green.opacity(0.8) : Color.white.opacity(0.05))
                )
                .cornerRadius(10)
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
    }
}
