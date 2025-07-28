import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Password attuale")) {
                    SecureField("Inserisci password attuale", text: $currentPassword)
                }
                
                Section(header: Text("Nuova password")) {
                    SecureField("Nuova password", text: $newPassword)
                    SecureField("Conferma nuova password", text: $confirmPassword)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
                Button(action: {
                    changePassword()
                }) {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Text("Cambia password")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isProcessing)
            }
            .navigationTitle("Cambia Password")
            .navigationBarItems(trailing: Button("Chiudi") {
                dismiss()
            })
        }
    }
    
    private func changePassword() {
        guard !currentPassword.isEmpty,
              !newPassword.isEmpty,
              !confirmPassword.isEmpty else {
            errorMessage = "Compila tutti i campi."
            successMessage = nil
            return
        }
        
        guard newPassword == confirmPassword else {
            errorMessage = "Le password non coincidono."
            successMessage = nil
            return
        }
        
        guard newPassword.count >= 6 else {
            errorMessage = "La nuova password deve avere almeno 6 caratteri."
            successMessage = nil
            return
        }
        
        errorMessage = nil
        successMessage = nil
        isProcessing = true
        
        // Re-authenticate user with current password
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            errorMessage = "Utente non autenticato."
            isProcessing = false
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = "Password attuale errata: \(error.localizedDescription)"
                successMessage = nil
                isProcessing = false
            } else {
                // Cambia la password
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        errorMessage = "Errore durante il cambio password: \(error.localizedDescription)"
                        successMessage = nil
                    } else {
                        successMessage = "Password cambiata con successo!"
                        errorMessage = nil
                        // Optional: chiudi la view dopo qualche secondo
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            dismiss()
                        }
                    }
                    isProcessing = false
                }
            }
        }
    }
}
