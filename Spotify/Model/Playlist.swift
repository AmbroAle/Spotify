import Foundation

struct Playlist: Identifiable, Codable {
    let id: String
    let name: String
    var trackIDs: [Int]
    var imageURL: String?
    let createdAt: Date

    init(id: String = UUID().uuidString, name: String, trackIDs: [Int], imageURL: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.trackIDs = trackIDs
        self.imageURL = imageURL
        self.createdAt = createdAt
    }
}
