import Foundation
import FirebaseAuth
import FirebaseFirestore

class AppViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var isRegistered = false
    
    private let db = Firestore.firestore()
    

        init() {
            self.isAuthenticated = Auth.auth().currentUser != nil
            _ = Auth.auth().addStateDidChangeListener { _, user in
                DispatchQueue.main.async {
                    self.isAuthenticated = (user != nil)
                }
            }

        }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Errore login: \(error.localizedDescription)"
                }
            } else if let user = result?.user {
                print("Login riuscito per UID: \(user.uid)")
                // Verifica se l'utente esiste nel database, altrimenti crealo
                self.checkOrCreateUserData(user: user, email: email)
                
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            }
        }
    }
    
    func register(email: String, password: String) {
        print("Inizio registrazione per: \(email)")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Errore registrazione Firebase Auth: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Errore registrazione: \(error.localizedDescription)"
                }
            } else if let user = result?.user {
                print("Utente creato con UID: \(user.uid)")
                // Salva i dati dell'utente nel database
                self.saveUserData(user: user, email: email)
                
                DispatchQueue.main.async {
                    self.isRegistered = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.isRegistered = false
                }
            }
        }
    }
    
    private func checkOrCreateUserData(user: User, email: String) {
        print("🔍 Controllo se l'utente esiste nel database...")
        
        db.collection("users").document(user.uid).getDocument { document, error in
            if let error = error {
                print("Errore nel controllo utente: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                print("Dati utente già esistenti")
            } else {
                print("Utente non trovato nel database, creazione in corso...")
                self.saveUserData(user: user, email: email)
            }
        }
    }
    
    private func saveUserData(user: User, email: String) {
        print("Inizio salvataggio dati per UID: \(user.uid)")
        
        // Estrai il nome utente dall'email (parte prima della @)
        let username = String(email.split(separator: "@").first ?? "Utente")
        
        let userData: [String: Any] = [
            "username": username,
            "email": email,
            "createdAt": Timestamp(date: Date()),
            "profileImageURL": "" // Campo vuoto inizialmente
        ]
        
        print("📝 Dati da salvare: \(userData)")
        
        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                print("Errore nel salvataggio dei dati utente: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Registrazione completata ma errore nel salvataggio dati: \(error.localizedDescription)"
                }
            } else {
                print("Dati utente salvati con successo in Firestore!")
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            } catch {
            print("Errore logout: \(error.localizedDescription)")
        }
    }
}
