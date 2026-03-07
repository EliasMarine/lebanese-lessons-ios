import SwiftUI

// MARK: - Liquid Glass Convenience

extension View {

    /// Fade-up entrance animation with an optional delay.
    func fadeUpAnimation(delay: Double = 0) -> some View {
        modifier(FadeUpModifier(delay: delay))
    }

    /// Shimmer loading placeholder effect.
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }

    /// Arabic text with tap-to-speak support.
    func speakable(_ text: String) -> some View {
        self.onTapGesture {
            Task { await AudioService.shared.speak(text) }
        }
    }
}

// MARK: - Fade Up Modifier

private struct FadeUpModifier: ViewModifier {
    let delay: Double

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 16)
            .onAppear {
                withAnimation(.easeOut(duration: 0.45).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.25),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.6)
                    .offset(x: phase * geometry.size.width * 1.6 - geometry.size.width * 0.3)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}
