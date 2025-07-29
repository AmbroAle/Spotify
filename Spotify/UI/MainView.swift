import SwiftUI

struct MainView: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch navigationManager.currentPage {
                case .home:
                    HomeView()
                case .library:
                    LibraryView()
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

#Preview {
    MainView()
        .environmentObject(AppViewModel())
        .environmentObject(NavigationManager()) 
}
