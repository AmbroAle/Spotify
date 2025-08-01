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
            HStack(spacing: 12) {
                Image(systemName: "bell.fill")
                    .foregroundColor(.white.opacity(0.9))
                    .imageScale(.large)
                
                Text(message)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                Button(action: {
                    notificationManager.inAppMessage = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.8))
                        .imageScale(.medium)
                }
            }
            .padding()
            .background(
                ZStack {
                    Color.white.opacity(0.1)
                        .blur(radius: 10)

                    LinearGradient(
                        colors: [Color.blue.opacity(0.25), Color.purple.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blendMode(.overlay)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 16)
        }
}
