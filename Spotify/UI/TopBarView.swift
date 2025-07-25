import SwiftUI

struct TopBarView: View {
    @Binding var selectedTab: String

    var body: some View {
        HStack(spacing: 20) {
            Image("UserIconDarkMode")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    tabButton(title: "Tutti")
                    tabButton(title: "Artisti")
                    tabButton(title: "Album")
                    tabButton(title: "Classifiche")
                }
            }
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
                .font(.caption)
                .foregroundColor(.white)
                .padding(10)
                .frame(minWidth: 90, maxWidth: 120)
                .background(
                    selectedTab == title ? Color.green.opacity(0.8) : Color.clear
                )
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1.2)
                )
        }
    }
}
