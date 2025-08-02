//
//  LocationManager.swift
//  Spotify
//
//  Created by Alex Frisoni on 02/08/25.
//


import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationString: String = "Posizione non disponibile"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    var onLocationUpdate: ((CLLocation) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        isLoading = true
        errorMessage = nil
        locationManager.requestLocation()
    }
    
    private func geocodeLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Errore geocoding: \(error.localizedDescription)"
                    self?.locationString = "Errore nel rilevare la posizione"
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    self?.locationString = "Posizione non trovata"
                    return
                }
                
                var components: [String] = []
                
                if let locality = placemark.locality {
                    components.append(locality)
                }
                
                if let administrativeArea = placemark.administrativeArea {
                    components.append(administrativeArea)
                }
                
                if let country = placemark.country {
                    components.append(country)
                }
                
                self?.locationString = components.isEmpty ? "Posizione sconosciuta" : components.joined(separator: ", ")
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.location = location
            self.onLocationUpdate?(location)  
        }
        geocodeLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = "Errore posizione: \(error.localizedDescription)"
            self.locationString = "Errore nel rilevare la posizione"
        }
    }
}
