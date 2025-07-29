//
//  ShareSheet.swift
//  Spotify
//
//  Created by Alex Frisoni on 29/07/25.
//


//
//  ShareSheet.swift
//  Spotify
//
//  Created by Alex Frisoni on 28/07/25.
//
import SwiftUI
import UIKit
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}