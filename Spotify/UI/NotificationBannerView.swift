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
                    .foregroundColor(.white)
                    .imageScale(.large)

                Text(message)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                Button {
                    withAnimation {
                        notificationManager.inAppMessage = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.85))
                        .imageScale(.medium)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
            .padding(.horizontal, 16)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        notificationManager.inAppMessage = nil
                    }
                }
            }
        }

}
