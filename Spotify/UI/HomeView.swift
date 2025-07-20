import SwiftUI

struct HomeView: View {
    @State private var selectedTab = "album"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBarView(selectedTab: $selectedTab)
                ScrollView {
                    VStack(spacing: 24) {
                        TrackCarouselView()
                        AlbumCarouselView()
                    }
                    .padding(.bottom, 16)
                }

                BottomMenuView()
            }
        }
    }
}

#Preview {
    HomeView()
}
