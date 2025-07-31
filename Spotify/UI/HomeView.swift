import SwiftUI

struct HomeView: View {
    @State private var selectedTab: String = ""
    @StateObject private var artistVM = ArtistViewModel()
    @StateObject private var albumVM = AlbumViewModel()
    @EnvironmentObject var profileVM: ProfileViewModel
    @StateObject var notificationManager = NotificationManager()


    var body: some View {
        NavigationStack {
            ZStack {
                NotificationBannerView().environmentObject(notificationManager)

                VStack(spacing: 10) {
                    TopBarView(selectedTab: $selectedTab, profileViewModel: profileVM, showNotification: showInAppNotification)
                        .frame(maxWidth: .infinity)
                    
                    contentView(for: selectedTab)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(.ultraThinMaterial)
                
                if let message = notificationManager.inAppMessage {
                    VStack {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.white)
                            Text(message)
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                            Spacer()
                            Button {
                                notificationManager.inAppMessage = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .top))
                    .animation(.easeInOut, value: notificationManager.inAppMessage)
                }
            }
            .environmentObject(notificationManager)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func showInAppNotification(_ message: String) {
        let inAppEnabled = UserDefaults.standard.bool(forKey: "inAppNotificationsEnabled")
        guard inAppEnabled else { return }
        notificationManager.show(message: message)
    }


    @ViewBuilder
    private func contentView(for tab: String) -> some View {
        switch tab {
        case "", "Tutti":
            ScrollView {
                VStack(spacing: 24) {
                    TrackCarouselView()
                    AlbumCarouselView()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        case "Artisti":
            ArtistView(viewModel: artistVM)
        case "Album":
            AlbumView(viewModel: albumVM)
        case "Classifiche":
            ClassificationView()
        default:
            ScrollView {
                VStack(spacing: 24) {
                    TrackCarouselView()
                    AlbumCarouselView()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
    }
}


#Preview {
    HomeView()
}
