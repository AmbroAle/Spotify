import SwiftUI
import PhotosUI
import LocalAuthentication

struct ProfileView: View {
    @StateObject private var locationManager = LocationManager()
    @ObservedObject var viewModel = ProfileViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    @AppStorage("useBiometric") private var useBiometric = false
    @State private var showingPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingCameraPicker = false
    @State private var showingSourceActionSheet = false
    @State private var showingSavedImages = false
    @State private var showingChangePassword = false
    @State private var showingCacheInfo = false
    @State private var showingNotifySettings = false
    @State private var showingLocationSettings = false
    
    var body: some View {
        VStack(spacing: 20) {
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
                profileRow(icon: "photo.fill", text: "Gestisci Foto Profilo") {
                    showingSavedImages = true
                }
                profileRow(icon: "location.circle.fill", text: "Posizione GPS") {
                    showingLocationSettings = true
                }
                profileRow(icon: "externaldrive.fill", text: "Info Cache (\(viewModel.getCacheSize()))") {
                    showingCacheInfo = true
                }
                profileRow(icon: "bell.fill", text: "Notifiche") {
                    showingNotifySettings = true
                }
                profileRow(icon: "lock.fill", text: "Password") {
                    if useBiometric {
                        authenticateBeforeShowingChangePassword()
                    } else {
                        showingChangePassword = true
                    }
                }
                profileRowWithToggle(icon: "faceid", text: "Face ID", isOn: $useBiometric)
                profileRow(icon: "rectangle.portrait.and.arrow.right", text: "Logout") {
                    appViewModel.logout()
                }
            }
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView().environmentObject(notificationManager)
            }
            .sheet(isPresented: $showingCacheInfo) {
                CacheInfoView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingNotifySettings) {
                NotifyView()
            }
            .sheet(isPresented: $showingLocationSettings){
                LocationSettingsView(locationManager: locationManager)
            }
            
            Spacer()
        }
        .padding()
        .overlay(
            NotificationBannerView()
                .environmentObject(notificationManager)
                , alignment: .top
        )
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
        }
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
    private func authenticateBeforeShowingChangePassword() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Autenticati per accedere alla modifica password"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        showingChangePassword = true
                    } else {
                        notificationManager.show(message: "Autenticazione fallita")
                    }
                }
            }
        } else {
            notificationManager.show(message: "Face ID non disponibile")
        }
    }

    private func profileRowWithToggle(icon: String, text: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 24)
            Text(text)
                .font(.body)
            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn.wrappedValue },
                set: { newValue in
                    if newValue {
                        let context = LAContext()
                        var error: NSError?

                        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                            let reason = "Autenticati per attivare il Face ID"
                            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                                DispatchQueue.main.async {
                                    if success {
                                        isOn.wrappedValue = true
                                    } else {
                                        isOn.wrappedValue = false
                                        notificationManager.show(message: "Autenticazione fallita")
                                    }
                                }
                            }
                        } else {
                            isOn.wrappedValue = false
                            notificationManager.show(message: "Face ID non disponibile")
                        }
                    } else {
                        isOn.wrappedValue = false
                    }
                }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 8)
    }

}

struct CacheInfoView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingCleanAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Informazioni Cache") {
                    HStack {
                        Text("Dimensione totale")
                        Spacer()
                        Text(viewModel.getCacheSize())
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Numero immagini")
                        Spacer()
                        Text("\(viewModel.savedProfileImages.count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Gestione Cache") {
                    Button("Pulisci immagini vecchie (30+ giorni)") {
                        showingCleanAlert = true
                    }
                    .foregroundColor(.orange)
                }
                
                Section("Note") {
                    Text("Le immagini del profilo sono salvate localmente sul dispositivo e non vengono sincronizzate. La pulizia automatica rimuove le immagini più vecchie di 30 giorni.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Gestione Cache")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                }
            }
            .alert("Pulisci Cache", isPresented: $showingCleanAlert) {
                Button("Annulla", role: .cancel) { }
                Button("Pulisci", role: .destructive) {
                    viewModel.cleanOldImages()
                }
            } message: {
                Text("Questa operazione rimuoverà tutte le immagini del profilo più vecchie di 30 giorni. L'operazione non può essere annullata.")
            }
        }
    }
    
}
