//
//  LocationSettingsView.swift
//  Spotify
//
//  Created by Alex Frisoni on 02/08/25.
//
import SwiftUI

struct LocationSettingsView: View {
    @ObservedObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Stato autorizzazione:")
                .font(.headline)

            Text(locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse ? "Autorizzato " : "Non autorizzato ")

            Text("Posizione corrente:")
                .font(.headline)

            Text(locationManager.locationString)
                .multilineTextAlignment(.center)

            if let location = locationManager.location {
                MapPreviewView(coordinate: location.coordinate)
            }

            if let error = locationManager.errorMessage {
                Text("Errore: \(error)")
                    .foregroundColor(.red)
            }

            Button("Aggiorna posizione") {
                locationManager.getCurrentLocation()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .onAppear {
            locationManager.requestLocationPermission()
        }
        .navigationTitle("Posizione GPS")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Chiudi") { dismiss() }
            }
        }
    }
}
