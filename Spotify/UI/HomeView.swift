import SwiftUI

struct HomeView: View {
    @State private var selectedTab = "album"
    @StateObject var viewModel = AlbumViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea() // Sfondo (puoi cambiarlo)

                VStack {
                    // 🔝 Sezione superiore: profilo + icone
                    HStack(spacing: 24) {
                        // Immagine profilo
                        Image("UserIcon")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))

                        // Icona artisti
                        VStack {
                            Image(systemName: "music.mic")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .onTapGesture {selectedTab = "artist"}
                            Text("Artisti")
                                .font(.caption)
                        }

                        // Icona album
                        VStack {
                            Image(systemName: "square.stack")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                            Text("Album")
                                .font(.caption)
                        }

                        Spacer()
                    }
                    .padding([.top, .horizontal])
                    .background(Color.black.opacity(0.1))

                    Spacer()
                    
                    Text("Album più popolari")
                        .font(.title2)
                        .bold()
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TabView {
                        ForEach(viewModel.albums) { album in
                            VStack {
                                AsyncImage(url: URL(string: album.cover_medium)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 250, height: 250)
                                .cornerRadius(16)

                                Text(album.title)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text(album.artist.name)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                            )
                            .padding(.horizontal, 16)
                            
                        }
                    }
                    .frame(height: 340) // altezza dell'area di scroll
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .task {
                        await viewModel.fetchNewReleases()
                    }
                    
                    // 🔻 Menu inferiore
                    HStack(spacing: 40) {
                        VStack {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Home")
                                .font(.caption2)
                        }

                        VStack {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Cerca")
                                .font(.caption2)
                        }

                        VStack {
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Impostazioni")
                                .font(.caption2)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
