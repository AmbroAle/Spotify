//
//  SpotifyApp.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 14/07/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
@main
struct SpotifyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var appViewModel = AppViewModel()
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var profileVM = ProfileViewModel()
    @StateObject var playlistPlayerVM = PlaylistPlayerViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(notificationManager)
                .environmentObject(appViewModel)
                .environmentObject(profileVM)
                .environmentObject(playlistPlayerVM) 
                .preferredColorScheme(.dark)
        }
    }
}

