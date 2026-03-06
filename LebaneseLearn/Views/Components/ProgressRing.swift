import SwiftUI

// MARK: - Progress Ring

/// A circular progress indicator with an optional center label.
///
/// Usage:
/// ```swift
/// ProgressRing(progress: 0.75, color: Theme.success)
/// ProgressRing(progress: 0.5, color: Theme.brand, lineWidth: 6, size: 60) {
///     Image(systemName: "checkmark")
/// }
/// ```
struct ProgressRing<CenterContent: View>: View {

    let progress: Double
    let color: Color
    var lineWidth: CGFloat
    var size: CGFloat
    let centerContent: CenterContent

    @State private var animatedProgress: Double = 0

    // MARK: - Initializers

    /// Create a progress ring with custom center content.
    init(
        progress: Double,
        color: Color,
        lineWidth: CGFloat = 4,
        size: CGFloat = 44,
        @ViewBuilder centerContent: () -> CenterContent
    ) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
        self.centerContent = centerContent()
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Track circle
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            // Center content
            centerContent
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = min(max(progress, 0), 1)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = min(max(newValue, 0), 1)
            }
        }
    }
}

// MARK: - Convenience Initializer (percentage text center)

extension ProgressRing where CenterContent == Text {

    /// Create a progress ring that shows the percentage in the center.
    init(
        progress: Double,
        color: Color,
        lineWidth: CGFloat = 4,
        size: CGFloat = 44
    ) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
        let pct = Int(min(max(progress, 0), 1) * 100)
        self.centerContent = Text("\(pct)%")
            .font(.nunito(size * 0.24, weight: .bold))
            .foregroundStyle(color)
    }
}

// MARK: - Convenience Initializer (empty center)

extension ProgressRing where CenterContent == EmptyView {

    /// Create a progress ring with no center content.
    init(
        progress: Double,
        color: Color,
        lineWidth: CGFloat = 4,
        size: CGFloat = 44,
        showLabel: Bool = false // disambiguator
    ) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
        self.centerContent = EmptyView()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        ProgressRing(progress: 0.75, color: Theme.success, size: 80)

        ProgressRing(progress: 0.4, color: Theme.brand, lineWidth: 6, size: 60) {
            Image(systemName: "star.fill")
                .foregroundStyle(Theme.brand)
        }

        ProgressRing(progress: 1.0, color: Theme.xpPurple, lineWidth: 8, size: 100)
    }
    .padding()
}
