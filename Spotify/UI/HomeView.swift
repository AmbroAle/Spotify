import SwiftUI

struct HomeView: View {
    @State private var selectedTab: String = ""
    @StateObject private var artistVM = ArtistViewModel()
    @StateObject private var albumVM = AlbumViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                TopBarView(selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
                    
                
                contentView(for: selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            .background(.ultraThinMaterial)
        }
        .navigationBarBackButtonHidden(true)
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
