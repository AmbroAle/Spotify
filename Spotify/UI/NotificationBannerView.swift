//
//  NotificationBannerView.swift
//  Spotify
//
//  Created by Alex Frisoni on 30/07/25.
//
import SwiftUI

struct NotificationBannerView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @AppStorage("inAppNotificationsEnabled") private var inAppEnabled: Bool = true

    var body: some View {
        if inAppEnabled, let message = notificationManager.inAppMessage {
            bannerView(message: message)
        } else {
            EmptyView()
        }
    }
    
    private func bannerView(message: String) -> some View {
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
        .transition(.move(edge: .top))
        .animation(.easeInOut, value: notificationManager.inAppMessage)
    }
}
