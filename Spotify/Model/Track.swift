//
//  Track.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 20/07/25.
//

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
}

struct DeezerTrackResponse: Codable {
    let data: [Track]
}
