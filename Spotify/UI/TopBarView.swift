import SwiftUI

struct TopBarView: View {
    @Binding var selectedTab: String
    @ObservedObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    var showNotification: (String) -> Void

    var body: some View {
        HStack(spacing: 14) {
            NavigationLink(destination:
                ProfileView(viewModel: profileViewModel)
                    .environmentObject(notificationManager)
                    .overlay(NotificationBannerView())
            ){
                profileImageView
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.leading, 6)
            }
            .buttonStyle(PlainButtonStyle())

            HStack(spacing: 10) {
                tabButton(title: "Artisti")
                tabButton(title: "Album")
                tabButton(title: "Classifiche")
            }
            .padding(.bottom, 5)
            Spacer()
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
    }
    
    private func tabButton(title: String) -> some View {
        LiquidGlassButton(
            title: title,
            action: {
                if selectedTab == title {
                    selectedTab = ""  // Torna alla home
                } else {
                    selectedTab = title  // Seleziona il nuovo tab
                }
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

    @ViewBuilder
        private var profileImageView: some View {
            if let imageData = profileViewModel.pickedImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let url = profileViewModel.userImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Image("UserIconDarkMode").resizable().scaledToFill()
                    @unknown default:
                        Image("UserIconDarkMode").resizable().scaledToFill()
                    }
                }
            } else {
                Image("UserIconDarkMode")
                    .resizable()
                    .scaledToFill()
            }
        }
    
}
