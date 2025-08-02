//
//  SecuritySettingsView.swift
//  Spotify
//
//  Created by Alex Frisoni on 02/08/25.
//


import SwiftUI
import LocalAuthentication

struct SecuritySettingsView: View {
    @AppStorage("biometricEnabled") private var biometricEnabled = false

    var body: some View {
        NavigationView {
            Form {
                Toggle("Usa Face ID / Touch ID", isOn: $biometricEnabled)
            }
            .navigationTitle("Sicurezza")
        }
    }
}
