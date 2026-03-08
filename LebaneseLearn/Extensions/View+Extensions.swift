import SwiftUI

// MARK: - Animation & Interaction Helpers

extension View {

    /// Bouncy fade-up entrance animation with an optional delay.
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

    /// Shake animation for wrong answers.
    func shake(trigger: Bool) -> some View {
        modifier(ShakeModifier(animating: trigger))
    }
}

// MARK: - Duo Press Button Style

/// Bouncy press animation — scales down on press with spring bounce-back.
struct DuoPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
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
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Shake Modifier

private struct ShakeModifier: ViewModifier {
    var animating: Bool
    @State private var shakeOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: animating) { _, newValue in
                guard newValue else { return }
                withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
                    shakeOffset = -10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
                        shakeOffset = 10
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
                        shakeOffset = -6
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                        shakeOffset = 0
                    }
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
                            Color.gray.opacity(0.15),
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
