import SwiftUI

struct HomeView: View {
    @State private var selectedTab = "album"

    var body: some View {
        NavigationStack {
            VStack {
                TopBarView(selectedTab: $selectedTab)
                AlbumCarouselView()
                Spacer()
                BottomMenuView()
            }
        }
    }
}

#Preview {
    HomeView()
}
