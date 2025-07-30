//
//  NotificationManager.swift
//  Spotify
//
//  Created by Alex Frisoni on 30/07/25.
//

import SwiftUI

class NotificationManager: ObservableObject {
    @Published var inAppMessage: String? = nil
    static let shared = NotificationManager()

    func show(message: String) {
        inAppMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.inAppMessage = nil
        }
    }
}
