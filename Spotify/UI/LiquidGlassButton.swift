import SwiftUI

struct LiquidGlassButton: View {
    let title: String
    let action: () -> Void
    let gradientColors: [Color] // colori per il gradiente
    var font: Font = .system(size: 24, weight: .medium)  // default
    var minwidth: CGFloat = 140
    var maxwidth: CGFloat = 200
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)   
                .foregroundColor(.white.opacity(0.85))
                .padding(.vertical, 12)
                .frame(minWidth: minwidth, maxWidth: maxwidth)
                .background(
                    ZStack {
                        Color.white.opacity(0.15)
                            .blur(radius: 10)

                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .blendMode(.overlay)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        .blur(radius: 1)
                        .mask(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.black, Color.clear]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        }
        
    }
}
