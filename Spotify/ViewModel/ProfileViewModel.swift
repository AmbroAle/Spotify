import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var username: String = "Caricamento..."
    @Published var email: String = ""
    @Published var userImageURL: URL?
    @Published var pickedImageData: Data?
    @Published var savedProfileImages: [ProfileImageData] = []

    private let db = Firestore.firestore()
    private let fileManager = FileManager.default
    private let imageFolderName = "ProfileImages"

    init() {
        createImagesDirectoryIfNeeded()
    }
    
    func fetchUserProfile() {
        print("🔄 Inizio fetch profilo utente...")
        
        guard let currentUser = Auth.auth().currentUser else {
            username = "Ospite"
            email = ""
            userImageURL = nil
            return
        }
        
        print("👤 Recupero dati per UID: \(currentUser.uid)")
        
        let userDocRef = db.collection("users").document(currentUser.uid)
        userDocRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                Task { @MainActor in
                    self.username = "Errore caricamento"
                }
                return
            }
            
            if let doc = document, doc.exists {
                let data = doc.data()
                
                let fetchedUsername = data?["username"] as? String ?? "Sconosciuto"
                let fetchedEmail = data?["email"] as? String ?? currentUser.email ?? ""
                
                Task { @MainActor in
                    self.username = fetchedUsername
                    self.email = fetchedEmail
                }
                
                self.loadLastLocalImage()
            } else {
                self.createMissingUserDocument(currentUser)
            }
        }
    }
    
    private func createMissingUserDocument(_ user: User) {
        let email = user.email ?? ""
        let username = String(email.split(separator: "@").first ?? "Utente")
        
        print("🆕 Creazione documento per utente: \(username)")
        
        let userData: [String: Any] = [
            "username": username,
            "email": email,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("users").document(user.uid).setData(userData) { [weak self] error in
            if let error = error {
                print("Errore creazione documento utente: \(error.localizedDescription)")
                Task { @MainActor in
                    self?.username = "Errore"
                }
            } else {
                Task { @MainActor in
                    self?.username = username
                    self?.email = email
                }
            }
        }
    }

    func changeProfileImage(_ imageData: Data) {
        pickedImageData = imageData
        saveProfileImageLocally(imageData)
    }

    private func saveProfileImageLocally(_ imageData: Data) {
        let timestamp = Date().timeIntervalSince1970
        let fileName = "profile_\(UUID().uuidString)_\(timestamp).jpg"
        
        guard let dirURL = getImagesDirectoryURL() else {
            return
        }
        
        let fileURL = dirURL.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            
            let imageMeta = ProfileImageData(
                id: fileName,
                localPath: fileURL.path,
                description: "Foto profilo del \(formattedDate(from: Date()))",
                timestamp: Date()
            )
            
            savedProfileImages.insert(imageMeta, at: 0)
            userImageURL = fileURL
            
        } catch {
            print("Errore salvataggio immagine: \(error)")
        }
    }

    func fetchSavedProfileImages() async {
        
        guard let dirURL = getImagesDirectoryURL() else {
            print("Directory non trovata")
            return
        }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [.creationDateKey])
            
            let images = contents.compactMap { url -> ProfileImageData? in
                guard fileManager.fileExists(atPath: url.path) else {
                    print("File non esistente: \(url.path)")
                    return nil
                }
                
                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let creationDate = attributes?[.creationDate] as? Date ?? Date()
                
                return ProfileImageData(
                    id: url.lastPathComponent,
                    localPath: url.path,
                    description: "Foto profilo salvata",
                    timestamp: creationDate
                )
            }.sorted(by: { $0.timestamp > $1.timestamp })
            
            savedProfileImages = images
            
        } catch {
            savedProfileImages = []
        }
    }

    func setAsCurrentProfileImage(_ path: String) {
        
        guard fileManager.fileExists(atPath: path) else {
            print("File immagine non trovato: \(path)")
            return
        }
        
        // Aggiorna l'URL dell'immagine corrente
        userImageURL = URL(fileURLWithPath: path)
        
        // Carica anche i dati dell'immagine per la visualizzazione immediata
        do {
            let imageData = try Data(contentsOf: URL(fileURLWithPath: path))
            pickedImageData = imageData
        } catch {
            print("Errore caricamento dati immagine: \(error)")
        }
    }

    func removeSavedProfileImage(_ id: String) {
        guard let imageToDelete = savedProfileImages.first(where: { $0.id == id }) else {
            print("Immagine non trovata per ID: \(id)")
            return
        }
        
        do {
            try fileManager.removeItem(atPath: imageToDelete.localPath)
            savedProfileImages.removeAll { $0.id == id }
            
            // Se era l'immagine corrente, rimuovi il riferimento
            if userImageURL?.path == imageToDelete.localPath {
                userImageURL = nil
                pickedImageData = nil
            }
            
        } catch {
            print("Errore rimozione immagine: \(error)")
        }
    }
    
    private func loadLastLocalImage() {
        
        Task {
            await fetchSavedProfileImages()
            if let lastImage = savedProfileImages.first {
                userImageURL = URL(fileURLWithPath: lastImage.localPath)
            } else {
                print("Nessuna immagine locale trovata")
            }
        }
    }

    // MARK: - Gestione Directory e Utility
    private func createImagesDirectoryIfNeeded() {
        guard let dirURL = getImagesDirectoryURL() else { return }
        
        if !fileManager.fileExists(atPath: dirURL.path) {
            do {
                try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Errore creazione cartella: \(error)")
            }
        }
    }

    private func getImagesDirectoryURL() -> URL? {
        let base = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        return base?.appendingPathComponent(imageFolderName)
    }

    func cleanOldImages(olderThan days: Int = 30) {
        
        guard let dirURL = getImagesDirectoryURL() else { return }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [.creationDateKey])
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            
            var deletedCount = 0
            for fileURL in contents {
                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                if let creationDate = attributes[.creationDate] as? Date,
                   creationDate < cutoffDate {
                    try fileManager.removeItem(at: fileURL)
                    deletedCount += 1
                }
            }
            
            
            Task {
                await fetchSavedProfileImages()
            }
            
        } catch {
            print("Errore pulizia immagini: \(error)")
        }
    }

    func getCacheSize() -> String {
        guard let dirURL = getImagesDirectoryURL() else { return "0 KB" }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [.fileSizeKey])
            let totalSize: Int64 = contents.reduce(0) { total, url in
                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let fileSize = attributes?[.size] as? Int64 ?? 0
                return total + fileSize
            }
            
            return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
            
        } catch {
            print("Errore calcolo dimensione cache: \(error)")
            return "N/A"
        }
    }

    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Errore logout: \(error.localizedDescription)")
        }
    }
}

struct ProfileImageData: Identifiable, Codable {
    let id: String
    let localPath: String
    let description: String
    let timestamp: Date
    
    var fileURL: URL {
        URL(fileURLWithPath: localPath)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: timestamp)
    }
}
