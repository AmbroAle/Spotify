//
//  TopBarView.swift
//  Spotify
//
//  Created by Alessandro Ambrogiani on 20/07/25.
//
import SwiftUI

struct TopBarView: View {
    @Binding var selectedTab: String

    var body: some View {
        HStack(spacing: 24) {
            Image("UserIcon")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 2))

            VStack {
                Image(systemName: "music.mic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .onTapGesture { selectedTab = "artist" }
                Text("Artisti").font(.caption)
            }

            VStack {
                Image(systemName: "square.stack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .onTapGesture { selectedTab = "album" }
                Text("Album").font(.caption)
            }

            Spacer()
        }
        .padding([.top, .horizontal])
        .background(Color.black.opacity(0.1))
    }
}
