import SwiftUI

struct HomeView: View {

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBarView()
                ScrollView {
                    VStack(spacing: 24) {
                        TrackCarouselView()
                        AlbumCarouselView()
                    }
                    .padding(.bottom, 16)
                }

                BottomMenuView()
            }
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    HomeView()
}
