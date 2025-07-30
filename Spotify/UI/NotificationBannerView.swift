//
//  NotificationBannerView.swift
//  Spotify
//
//  Created by Alex Frisoni on 30/07/25.
//


import SwiftUI

struct NotificationBannerView: View {
    @EnvironmentObject var notificationManager: NotificationManager

    var body: some View {
        if let message = notificationManager.inAppMessage {
            VStack {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.white)
                    Text(message)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    Spacer()
                    Button {
                        notificationManager.inAppMessage = nil
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer()
            }
            .transition(.move(edge: .top))
            .animation(.easeInOut, value: message)
        }
    }
}
