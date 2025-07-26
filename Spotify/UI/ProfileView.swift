import SwiftUI
import PhotosUI
import FirebaseStorage

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingCameraPicker = false
    @State private var showingSourceActionSheet = false

    var body: some View {
        VStack(spacing: 20) {
            // Immagine profilo tappabile con scelta sorgente immagine
            ZStack(alignment: .bottomTrailing) {
                profileImageView
                    .onTapGesture {
                        showingSourceActionSheet = true
                    }

                Image(systemName: "camera.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .padding(6)
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .shadow(radius: 8)
            .padding(.top, 40)

            Text(viewModel.username)
                .font(.title)
                .fontWeight(.bold)

            Text(viewModel.email)
                .font(.subheadline)
                .foregroundColor(.gray)

            Divider().padding(.vertical, 20)

            // Voci per il profilo
            VStack(spacing: 15) {
                profileRow(icon: "gearshape.fill", text: "Impostazioni") {
                    // probabilmente da rimuovere dato che lo faremo nella bottomBar
                }
                profileRow(icon: "lock.fill", text: "Privacy") {
                    // Da vedere se si riesce ad implementare
                }
                profileRow(icon: "rectangle.portrait.and.arrow.right", text: "Logout") {
                    viewModel.logout()
                    // Implementare
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.fetchUserProfile()
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedItem, matching: .images)
        .task(id: selectedItem) {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                viewModel.pickedImageData = data
                viewModel.changeProfileImage(data)
            }
        }

        .sheet(isPresented: $showingCameraPicker) {
            CameraPicker { image in
                if let data = image.jpegData(compressionQuality: 0.8) {
                    viewModel.pickedImageData = data
                    viewModel.changeProfileImage(data)
                }
            }
        }
        .actionSheet(isPresented: $showingSourceActionSheet) {
            ActionSheet(title: Text("Seleziona sorgente immagine"), buttons: [
                .default(Text("Libreria Foto")) {
                    showingPhotoPicker = true
                },
                .default(Text("Fotocamera")) {
                    showingCameraPicker = true
                },
                .cancel()
            ])
        }
        .navigationTitle("Profilo")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var profileImageView: some View {
        if let imageData = viewModel.pickedImageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if let url = viewModel.userImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty: ProgressView()
                case .success(let image): image.resizable().scaledToFill()
                case .failure: Image("UserIconDarkMode").resizable().scaledToFill()
                @unknown default: Image("UserIconDarkMode").resizable().scaledToFill()
                }
            }
        } else {
            Image("UserIconDarkMode")
                .resizable()
                .scaledToFill()
        }
    }

    private func profileRow(icon: String, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.green)
                    .frame(width: 24)
                Text(text)
                    .font(.body)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
