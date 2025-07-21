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
}
