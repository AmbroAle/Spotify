//
//  RootView.swift
//  Spotify
//
//  Created by Alex Frisoni on 28/07/25.
//


import SwiftUI

struct RootView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        Group {
            if appViewModel.isAuthenticated {
                HomeView()
                    .environmentObject(appViewModel)
            } else {
                LoginView()
                    .environmentObject(appViewModel)
            }
        }
    }
}
