import SwiftUI

// MARK: - Card Style

extension View {

    /// Applies the standard card appearance: background, corner radius, border, and shadow.
    func cardStyle() -> some View {
        modifier(CardStyleModifier())
    }

    /// Applies the branded primary button style (success green gradient).
    func primaryButton() -> some View {
        modifier(PrimaryButtonModifier())
    }

    /// Fade-up entrance animation with an optional delay.
    func fadeUpAnimation(delay: Double = 0) -> some View {
        modifier(FadeUpModifier(delay: delay))
    }

    /// Shimmer loading placeholder effect.
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Card Style Modifier

private struct CardStyleModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(Theme.bgCardAdaptive(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .strokeBorder(Theme.border(for: colorScheme), lineWidth: 1)
            )
            .shadow(
                color: Theme.cardShadow(for: colorScheme),
                radius: 8,
                x: 0,
                y: 4
            )
    }
}

// MARK: - Primary Button Modifier

private struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.nunito(16, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Theme.success, Theme.success.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius, style: .continuous))
            .shadow(color: Theme.success.opacity(0.3), radius: 6, x: 0, y: 3)
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
