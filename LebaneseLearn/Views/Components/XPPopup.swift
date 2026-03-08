import SwiftUI

// MARK: - XP Popup

/// A bold floating "+X XP" badge that bounces in and floats away.
struct XPPopup: View {

    @Binding var xpAmount: Int?

    @State private var offsetY: CGFloat = 16
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5

    var body: some View {
        if let amount = xpAmount {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.nunito(22, weight: .bold))
                    .foregroundStyle(Theme.duoYellow)
                Text("+\(amount) XP")
                    .font(.nunito(28, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Theme.duoGreen)
            .clipShape(Capsule())
            .shadow(color: Theme.duoGreenDark.opacity(0.5), radius: 0, x: 0, y: 4)
            .scaleEffect(scale)
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                // Bounce in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    opacity = 1
                    offsetY = -10
                    scale = 1.15
                }

                // Settle
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.3)) {
                    scale = 1.0
                }

                // Float up and fade out
                withAnimation(.easeIn(duration: 0.6).delay(1.0)) {
                    opacity = 0
                    offsetY = -70
                    scale = 0.8
                }

                // Reset state after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    xpAmount = nil
                    offsetY = 16
                    opacity = 0
                    scale = 0.5
                }
            }
            .allowsHitTesting(false)
        }
    }
}

// MARK: - XP Popup Modifier

/// View modifier for easy attachment of an XP popup to any view.
struct XPPopupModifier: ViewModifier {
    @Binding var xpAmount: Int?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                XPPopup(xpAmount: $xpAmount)
                    .padding(.top, 20)
            }
    }
}

extension View {
    /// Attach an XP popup to the view. Set the binding to trigger the animation.
    func xpPopup(amount: Binding<Int?>) -> some View {
        modifier(XPPopupModifier(xpAmount: amount))
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var xp: Int? = 25
        var body: some View {
            VStack {
                Button("Show XP") { xp = 50 }
                    .font(.nunito(16, weight: .bold))
                    .duoButtonProminent()
                    .buttonStyle(DuoPressStyle())
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .xpPopup(amount: $xp)
        }
    }
    return PreviewWrapper()
}
