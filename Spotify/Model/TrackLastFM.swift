struct TopTracksResponse: Decodable {
    let tracks: TracksContainer
}

struct TracksContainer: Decodable {
    let track: [TrackLastFM]
}

struct TrackLastFM: Decodable, Identifiable {
    var id: String { nameTrack + nameArtist }

    let nameTrack: String
    let nameArtist: String
    let sizeMedium: String

    enum CodingKeys: String, CodingKey {
        case name
        case artist
        case image
    }

    enum ArtistKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        nameTrack = try container.decode(String.self, forKey: .name)

        let artistContainer = try container.nestedContainer(keyedBy: ArtistKeys.self, forKey: .artist)
        nameArtist = try artistContainer.decode(String.self, forKey: .name)

        let images = try container.decode([ImageInfo].self, forKey: .image)
        sizeMedium = images.first(where: { $0.size == "medium" })?.url ?? ""
    }
}

struct ImageInfo: Codable {
    let url: String
    let size: String

    enum CodingKeys: String, CodingKey {
        case url = "#text"
        case size
    }
}
