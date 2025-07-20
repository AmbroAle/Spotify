//
//  BottomMenuView.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 20/07/25.
//
import SwiftUI

struct BottomMenuView: View {
    var body: some View {
        HStack(spacing: 40) {
            VStack {
                Image(systemName: "house.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Home").font(.caption2)
            }
            VStack {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Cerca").font(.caption2)
            }
            VStack {
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Impostazioni").font(.caption2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}
