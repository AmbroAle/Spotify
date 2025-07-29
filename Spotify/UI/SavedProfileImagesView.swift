import SwiftUI

struct SavedProfileImagesView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var imageToDelete: ProfileImageData?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.savedProfileImages.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Nessuna foto profilo salvata")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("Le foto del profilo che salvi appariranno qui")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.savedProfileImages) { image in
                            HStack(spacing: 12) {
                                // Immagine profilo
                                AsyncImage(url: URL(fileURLWithPath: image.localPath)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 60, height: 60)
                                    case .success(let img):
                                        img
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                    case .failure:
                                        Image(systemName: "photo.circle.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray.opacity(0.5))
                                    @unknown default:
                                        Image(systemName: "photo.circle.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                }
                                
                                // Info immagine
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(image.description)
                                        .font(.headline)
                                        .lineLimit(2)
                                    
                                    Text(image.formattedDate)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    // Indicatore se è l'immagine corrente
                                    if viewModel.userImageURL?.path == image.localPath {
                                        Text("✓ Immagine corrente")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 8) {
                                    Button(action: {
                                        print("Impostando come immagine profilo: \(image.localPath)")
                                        viewModel.setAsCurrentProfileImage(image.localPath)
                                        
                                        // Aggiorno subito per mostrare l'immagine appena impostata
                                        if let imageData = try? Data(contentsOf: URL(fileURLWithPath: image.localPath)) {
                                            viewModel.pickedImageData = imageData
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            dismiss()
                                        }
                                    }) {
                                        if viewModel.userImageURL?.path == image.localPath {
                                            Text("Corrente")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(viewModel.userImageURL?.path == image.localPath ? Color.gray : Color.green)
                                                .cornerRadius(8)
                                        } else {
                                            Text("") 
                                        }
                                    }
                                    .disabled(viewModel.userImageURL?.path == image.localPath)
                                    
                                    Button(action: {
                                        imageToDelete = image
                                        showAlert = true
                                    }) {
                                        Text("Elimina")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.red)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Foto Profilo (\(viewModel.savedProfileImages.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
            .alert("Elimina Foto", isPresented: $showAlert) {
                Button("Annulla", role: .cancel) {
                    imageToDelete = nil
                }
                Button("Elimina", role: .destructive) {
                    if let image = imageToDelete {
                        print("🗑️ Eliminando immagine: \(image.id)")
                        viewModel.removeSavedProfileImage(image.id)
                    }
                    imageToDelete = nil
                }
            } message: {
                Text("Sei sicuro di voler eliminare questa foto del profilo? L'operazione non può essere annullata.")
            }
        }
        .onAppear {
            print("📱 SavedProfileImagesView: Aggiornamento lista immagini...")
            Task {
                await viewModel.fetchSavedProfileImages()
            }
        }
    }
}
