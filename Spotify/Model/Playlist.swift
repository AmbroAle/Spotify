import Foundation

struct Playlist: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var trackIDs: [String]
    var createdAt: Date
}
