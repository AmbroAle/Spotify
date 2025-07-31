import SwiftUI

struct MainView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var profileVM: ProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch navigationManager.currentPage {
                case .home:
                    HomeView()
                case .library:
                    LibraryView(profileViewModel: profileVM)
                case .create:
                    CreatePlaylistView()
                case .none:
                    HomeView()
                }
            }

            BottomMenuView()
        }
    }
}
