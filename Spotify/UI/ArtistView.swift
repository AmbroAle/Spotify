import SwiftUI

struct ArtistView: View {
    @StateObject private var viewModel = ArtistViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack(){
            VStack {
                TextField("Cerca artista...", text: $viewModel.searchQuery)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding([.horizontal, .top])
                    .onChange(of: viewModel.searchQuery) {
                        Task {
                            await viewModel.searchArtists()
                        }
                    }

                List(viewModel.artists) { artist in
                    NavigationLink(destination: ArtistDetailView(artist: artist)){
                        HStack {
                            AsyncImage(url: URL(string: artist.picture_medium)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            Text(artist.name)
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationTitle("Artisti")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
            BottomMenuView()
        }
    }
}
