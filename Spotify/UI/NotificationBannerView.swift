//
//  NotificationBannerView.swift
//  Spotify
//
//  Created by Alex Frisoni on 30/07/25.
//
import SwiftUI
import SwiftUI

struct NotificationBannerView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @AppStorage("inAppNotificationsEnabled") private var inAppEnabled: Bool = true

    var body: some View {
        if inAppEnabled, let message = notificationManager.inAppMessage {
            bannerView(message: message)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: notificationManager.inAppMessage)
        } else {
            EmptyView()
        }
    }
    
    private func bannerView(message: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
            }

            Text(message)
                .foregroundColor(.white)
                .font(.system(size: 15, weight: .medium))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                    notificationManager.inAppMessage = nil
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "xmark")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.95),
                        Color(red: 0.0, green: 0.7, blue: 0.4).opacity(0.9),
                        Color(red: 0.0, green: 0.6, blue: 0.3).opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.25),
                        Color.clear,
                        Color.black.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.green.opacity(0.3), radius: 15, x: 0, y: 8)
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .onAppear {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    notificationManager.inAppMessage = nil
                }
            }
        }
    }
}
