
import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isRegistered = false
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Errore login: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            }
        }
    }
    
    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Errore registrazione: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    self.isRegistered = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.isRegistered = false
                }
            }
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
        isAuthenticated = false
    }
}
