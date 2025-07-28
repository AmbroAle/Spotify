import SwiftUI
import PhotosUI
import FirebaseStorage

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingCameraPicker = false
    @State private var showingSourceActionSheet = false
    @State private var showingSavedImages = false // per lo storico delle immagini profilo
    @State private var showingChangePassword = false

    var body: some View {
        VStack(spacing: 20) {
            // Immagine profilo corrente
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

            // bottone per vedere foto profilo salvate
            if !viewModel.savedProfileImages.isEmpty {
                Button("Foto Profilo Salvate (\(viewModel.savedProfileImages.count))") {
                    showingSavedImages = true
                }
                .foregroundColor(.blue)
                .padding(.top, 10)
            }

            Divider().padding(.vertical, 20)

            // Voci per il profilo (codice esistente)
            VStack(spacing: 15) {
                profileRow(icon: "photo.fill", text: "Gestisci Foto Profilo") {
                    showingSavedImages = true
                }
                profileRow(icon: "gearshape.fill", text: "Impostazioni") {
                    // Da implementare
                }
                profileRow(icon: "lock.fill", text: "Privacy") {
                    showingChangePassword = true
                }
                profileRow(icon: "rectangle.portrait.and.arrow.right", text: "Logout") {
                    appViewModel.logout()
                }
            }
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.fetchUserProfile()
            Task {
                await viewModel.fetchSavedProfileImages()
            }
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
        .sheet(isPresented: $showingSavedImages) {
            SavedProfileImagesView(viewModel: viewModel)
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

struct SavedProfileImagesView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.savedProfileImages) { image in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: image.imageURL)) { phase in
                            switch phase {
                            case .empty: ProgressView()
                            case .success(let img): img.resizable().scaledToFill()
                            case .failure: Image("UserIconDarkMode").resizable().scaledToFill()
                            @unknown default: Image("UserIconDarkMode").resizable().scaledToFill()
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(image.description)
                                .font(.headline)
                                .lineLimit(2)
                            
                            Text(image.formattedDate)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 16) {
                                Button("Usa come profilo") {
                                    viewModel.setAsCurrentProfileImage(image.imageURL)
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                
                                Button("Elimina") {
                                    viewModel.removeSavedProfileImage(image.id, imageURL: image.imageURL)
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Foto Profilo Salvate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
    }
}
