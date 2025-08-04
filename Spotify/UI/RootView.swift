//
//  RootView.swift
//  Spotify
//
//  Created by Alex Frisoni on 28/07/25.
//


import SwiftUI

struct RootView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var notificationManager = NotificationManager()

    var body: some View {
        Group {
            if appViewModel.isAuthenticated {
                MainView()
                    .environmentObject(appViewModel)
                    .environmentObject(navigationManager)
                    .environmentObject(notificationManager)
            } else {
                LoginView()
                    .environmentObject(appViewModel)
            }
        }
        .overlay(
                    NotificationBannerView()
                        .environmentObject(notificationManager)
                        .ignoresSafeArea(.all, edges: .top)
                        .zIndex(9999),
                    alignment: .top
                )
    }
}
