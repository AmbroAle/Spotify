import SwiftUI

struct SavedProfileImagesView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.savedProfileImages) { image in
                    HStack(spacing: 12) {
                        // ✅ MODIFICATO: Usa localPath invece di imageURL
                        AsyncImage(url: URL(fileURLWithPath: image.localPath)) { phase in
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
                                    // ✅ MODIFICATO: Usa localPath invece di imageURL
                                    viewModel.setAsCurrentProfileImage(image.localPath)
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                
                                Button("Elimina") {
                                    // ✅ MODIFICATO: Rimosso parametro imageURL
                                    viewModel.removeSavedProfileImage(image.id)
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
