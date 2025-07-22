import Foundation

struct Track: Identifiable, Codable {
    let id: Int
    let title: String
    let preview: String
    let artist: Artist
    let album: TrackAlbum
}

struct TrackAlbum: Codable {
    let cover_medium: String
    let title: String
}

struct TrackAlbumDetail : Codable , Identifiable{
    let id: Int
    let title: String
    let preview: String
}

struct DeezerTrackResponse: Codable {
    let data: [Track]
}
