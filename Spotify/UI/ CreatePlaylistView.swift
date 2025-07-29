import SwiftUI

struct CreatePlaylistView: View {
    @StateObject private var viewModel = CreatePlaylistViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Grip bar
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text("Crea nuova playlist")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)

            VStack(spacing: 16) {
                TextField("Nome della playlist", text: $viewModel.playlistName)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                Button(action: {
                    viewModel.savePlaylist()
                    dismiss()
                }) {
                    Text(viewModel.isSaving ? "Creazione in corso..." : "Crea playlist")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.playlistName.isEmpty ? Color.gray.opacity(0.5) : Color.green)
                        .foregroundColor(.white)
                        .font(.headline)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
                .disabled(viewModel.playlistName.isEmpty || viewModel.isSaving)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            Spacer()
        }
        .padding(.bottom, 24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.bottom)
        )
    }
}
