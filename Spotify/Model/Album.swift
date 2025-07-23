//
//  Album.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 20/07/25.
//

struct Album: Codable, Identifiable {
    let id: Int
    let title: String
    let cover_medium: String
    let release_date: String
    var artist: AlbumArtist?
}

struct SearchedAlbum: Codable,Identifiable {
    let id: Int
    let title: String
    let cover_medium: String
    let artist: AlbumArtist
}


struct AlbumArtist: Codable {
    let name: String
}

struct DeezerResponse<T: Codable>: Codable {
    let data: [T]
}
