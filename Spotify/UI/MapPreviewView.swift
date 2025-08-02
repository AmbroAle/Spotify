//
//  MapPreviewView.swift
//  Spotify
//
//  Created by Alex Frisoni on 02/08/25.
//
import SwiftUI
import MapKit

struct MapPreviewView: View {
    let coordinate: CLLocationCoordinate2D
    @State private var camera: MapCameraPosition

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        _camera = State(initialValue: .region(
            MKCoordinateRegion(center: coordinate,
                               span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        ))
    }

    var body: some View {
        Map(position: $camera) {
            Marker("Posizione Attuale", coordinate: coordinate)
        }

        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }
}
