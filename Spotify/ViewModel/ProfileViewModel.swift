// Aggiornamento completo di ProfileViewModel.swift e ProfileView.swift per salvataggio locale
// Percorso: ../Images per salvare immagini profilo utente in locale senza Firebase

import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var username: String = "Utente Locale"
    @Published var email: String = ""
    @Published var userImageURL: URL?
    @Published var pickedImageData: Data?
    @Published var savedProfileImages: [ProfileImageData] = []

    private let fileManager = FileManager.default
    private let imageFolderName = "Images"

    init() {
        createImagesDirectoryIfNeeded()
    }

    // MARK: - Salvataggio Immagine Profilo in Locale

    func changeProfileImage(_ imageData: Data) {
        pickedImageData = imageData
        saveProfileImageLocally(imageData)
    }

    private func saveProfileImageLocally(_ imageData: Data) {
        let timestamp = Date().timeIntervalSince1970
        let fileName = "profile_\(timestamp).jpg"

        guard let dirURL = getImagesDirectoryURL() else { return }
        let fileURL = dirURL.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL)
            print("✅ Immagine salvata localmente in: \(fileURL.path)")

            let imageMeta = ProfileImageData(
                id: fileName,
                localPath: fileURL.path,
                description: "Foto profilo del \(formattedDate(from: Date()))",
                timestamp: Date()
            )

            savedProfileImages.insert(imageMeta, at: 0)
            userImageURL = fileURL

        } catch {
            print("❌ Errore salvataggio immagine locale: \(error)")
        }
    }

    func fetchSavedProfileImages() async {
        guard let dirURL = getImagesDirectoryURL() else { return }
        do {
            let contents = try fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil)
            let images = contents.compactMap { url -> ProfileImageData? in
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
            print("❌ Errore caricamento immagini locali: \(error)")
        }
    }

    func setAsCurrentProfileImage(_ path: String) {
        userImageURL = URL(fileURLWithPath: path)
    }

    func removeSavedProfileImage(_ id: String) {
        guard let imageToDelete = savedProfileImages.first(where: { $0.id == id }) else { return }
        do {
            try fileManager.removeItem(atPath: imageToDelete.localPath)
            savedProfileImages.removeAll { $0.id == id }
            print("🗑️ Immagine rimossa: \(imageToDelete.localPath)")
        } catch {
            print("❌ Errore rimozione immagine: \(error)")
        }
    }

    private func createImagesDirectoryIfNeeded() {
        guard let dirURL = getImagesDirectoryURL() else { return }
        if !fileManager.fileExists(atPath: dirURL.path) {
            do {
                try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
                print("📁 Cartella immagini creata: \(dirURL.path)")
            } catch {
                print("❌ Errore creazione cartella immagini: \(error)")
            }
        }
    }

    private func getImagesDirectoryURL() -> URL? {
        let base = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        return base?.appendingPathComponent("Images")
    }

    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
        return formatter.string(from: timestamp)
    }
}
