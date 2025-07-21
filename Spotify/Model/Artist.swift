//
//  Artist.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 21/07/25.
//

import Foundation

struct Artist: Identifiable, Codable {
    let id: Int
    let name: String
    let picture_medium: String
    let picture_big: String
}

struct TopTagsResponse: Codable {
    let toptags: TopTags
}

struct TopTags: Codable {
    let tag: [GenreTag]
}

struct GenreTag: Codable {
    let name: String
    let count: Int
}
