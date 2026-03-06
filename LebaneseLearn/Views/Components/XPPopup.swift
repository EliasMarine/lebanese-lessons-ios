import SwiftUI

// MARK: - XP Popup

/// A floating "+X XP" text that animates upward and fades out.
///
/// Usage:
/// ```swift
/// @State private var xpGained: Int? = nil
///
/// ZStack {
///     // ... main content ...
///     XPPopup(xpAmount: $xpGained)
/// }
///
/// // Trigger it:
/// xpGained = 25
/// ```
struct XPPopup: View {

    @Binding var xpAmount: Int?

    @State private var isVisible = false
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        if let amount = xpAmount {
            Text("+\(amount) XP")
                .font(.nunito(24, weight: .bold))
                .foregroundStyle(Theme.success)
                .shadow(color: Theme.success.opacity(0.4), radius: 6, x: 0, y: 2)
                .offset(y: offsetY)
                .opacity(opacity)
                .onAppear {
                    // Animate in: float up and appear
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 1
                        offsetY = -10
                    }

                    // Animate out: continue floating and fade
                    withAnimation(.easeIn(duration: 0.6).delay(0.8)) {
                        opacity = 0
                        offsetY = -60
                    }

                    // Reset state after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        xpAmount = nil
                        offsetY = 0
                        opacity = 0
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
                    .primaryButton()
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .xpPopup(amount: $xp)
        }
    }

    return PreviewWrapper()
}
