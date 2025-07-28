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

    var body: some View {
        Group {
            if appViewModel.isAuthenticated {
                MainView()
                    .environmentObject(appViewModel)
                    .environmentObject(navigationManager)
            } else {
                LoginView()
                    .environmentObject(appViewModel)
            }
        }
    }
}
