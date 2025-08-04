import SwiftUI
import Foundation

struct CreatePlaylistView: View {
    @StateObject private var viewModel = CreatePlaylistViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationManager: NotificationManager

    var body: some View {
        VStack(spacing: 24) {
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
                    let savedPlaylistName = viewModel.playlistName
                    viewModel.savePlaylist()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if viewModel.errorMessage != nil {
                            if let error = viewModel.errorMessage {
                                if error.contains("non autenticato") {
                                    notificationManager.show(message: "Errore: utente non autenticato")
                                } else if error.contains("vuoto") || savedPlaylistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    notificationManager.show(message: "Inserisci un nome per la playlist")
                                } else {
                                    notificationManager.show(message: "Errore nella creazione della playlist")
                                }
                            }
                        } else if !viewModel.isSaving && viewModel.playlistName.isEmpty {
                            notificationManager.show(message: "Playlist '\(savedPlaylistName)' creata con successo!")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        }
                    }
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
