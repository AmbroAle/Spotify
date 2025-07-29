import SwiftUI

struct LibraryView: View {
    @State private var showAddArtistSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Intestazione: Immagine + titolo
                    HStack {
                        Image("UserIconDarkMode")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                        Text("La tua libreria")
                            .font(.title2)
                            .bold()

                        Spacer()
                    }
                    .padding(.horizontal)

                    // NavigationLink ai brani piaciuti
                    VStack(alignment: .leading) {
                        NavigationLink {
                            // LikedTracksView() — da implementare
                            Text("Brani con like")
                        } label: {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 24, height: 24)

                                Text("Brani che ti piacciono")
                                    .font(.headline)

                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    // Lista di playlist (placeholder)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Le tue playlist")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(0..<3, id: \.self) { index in
                            NavigationLink {
                                // PlaylistDetailView(...) — da implementare
                                Text("Dettagli playlist \(index + 1)")
                            } label: {
                                HStack {
                                    Image(systemName: "music.note.list")
                                        .foregroundColor(.blue)
                                        .frame(width: 24, height: 24)

                                    Text("Playlist \(index + 1)")
                                        .font(.body)

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(.thinMaterial)
                                .cornerRadius(10)
                            }
                        }
                    }

                    // Bottone per aggiungere artista
                    Button {
                        showAddArtistSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Aggiungi artista")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .sheet(isPresented: $showAddArtistSheet) {
                // AddArtistView() — da implementare
                Text("Aggiungi artista")
                    .font(.title)
                    .padding()
            }
        }
    }
}

#Preview {
    LibraryView()
}
