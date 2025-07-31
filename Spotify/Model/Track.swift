import Foundation
import FirebaseFirestore

struct Track: Identifiable, Codable {
    let id: Int
    let title: String
    let preview: String
    let artist: Artist
    let album: TrackAlbum
}

struct TrackAlbum: Codable {
    let id: Int
    let cover_medium: String
    let title: String
}

struct TrackAlbumDetail: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let preview: String
    let cover_medium: String?
    let artistName: String

    enum CodingKeys: String, CodingKey {
        case id, title, preview, album, artist
    }

    enum AlbumKeys: String, CodingKey {
        case cover_medium
    }

    enum ArtistKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        preview = try container.decode(String.self, forKey: .preview)

        // Decodifica immagine album
        if let albumContainer = try? container.nestedContainer(keyedBy: AlbumKeys.self, forKey: .album) {
            cover_medium = try? albumContainer.decode(String.self, forKey: .cover_medium)
        } else {
            cover_medium = nil
        }

        // Decodifica artista
        let artistContainer = try container.nestedContainer(keyedBy: ArtistKeys.self, forKey: .artist)
        artistName = try artistContainer.decode(String.self, forKey: .name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(preview, forKey: .preview)

        if let cover = cover_medium {
            var albumContainer = container.nestedContainer(keyedBy: AlbumKeys.self, forKey: .album)
            try albumContainer.encode(cover, forKey: .cover_medium)
        }

        var artistContainer = container.nestedContainer(keyedBy: ArtistKeys.self, forKey: .artist)
        try artistContainer.encode(artistName, forKey: .name)
    }
}

struct TrackRecentPlay : Codable, Identifiable {
    let id: Int
    let title: String
    let preview: String
    let timestamp: Timestamp
}


struct DeezerTrackResponse: Codable {
    let data: [Track]
}
