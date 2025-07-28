import SwiftUI

struct SavedProfileImagesView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.savedProfileImages) { image in
                    SavedProfileImageRow(image: image, viewModel: viewModel)
                        .padding(.vertical, 4)
                }
            }
            .navigationTitle("Foto Profilo Salvate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
    }
}

struct SavedProfileImageRow: View {
    let image: ProfileImageData
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        HStack(spacing: 12) {
            profileImage
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
                        viewModel.setAsCurrentProfileImage(image.localPath)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)

                    Button("Elimina") {
                        viewModel.removeSavedProfileImage(image.id)
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var profileImage: some View {
        if let data = try? Data(contentsOf: image.fileURL),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Image("UserIconDarkMode")
                .resizable()
                .scaledToFill()
        }
    }
}
