import SwiftUI

/// A burst of colorful confetti particles that fall from the top.
/// Triggered via a Bool binding — auto-dismisses after ~2.5 seconds.
struct ConfettiView: View {
    @Binding var isActive: Bool

    @State private var particles: [ConfettiParticle] = []

    private static let colors: [Color] = [
        Theme.duoGreen, Theme.duoOrange, Theme.duoBlue,
        Theme.duoRed, Theme.duoYellow, Theme.duoPurple,
        Theme.hotPink, Color(hex: "#89E219"),
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    particle.shape
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    launchConfetti(in: geometry.size)
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func launchConfetti(in size: CGSize) {
        // Generate particles at the top
        particles = (0..<45).map { _ in
            ConfettiParticle(
                color: Self.colors.randomElement()!,
                size: CGFloat.random(in: 6...12),
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -40...(-10)),
                rotation: Double.random(in: 0...360),
                opacity: 1.0,
                isCircle: Bool.random()
            )
        }

        // Animate particles falling down
        for i in particles.indices {
            let delay = Double.random(in: 0...0.4)
            let duration = Double.random(in: 1.2...2.2)
            let targetY = size.height + 40
            let drift = CGFloat.random(in: -60...60)

            withAnimation(.easeIn(duration: duration).delay(delay)) {
                particles[i].y = targetY
                particles[i].x += drift
                particles[i].rotation += Double.random(in: 180...720)
            }
            withAnimation(.easeIn(duration: 0.5).delay(delay + duration - 0.5)) {
                particles[i].opacity = 0
            }
        }

        // Auto-dismiss after particles have fallen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            isActive = false
            particles = []
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var opacity: Double
    let isCircle: Bool

    var shape: AnyShape {
        isCircle ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 2))
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var showConfetti = false
        var body: some View {
            ZStack {
                VStack {
                    Button("Celebrate!") { showConfetti = true }
                        .duoButtonProminent()
                }
                ConfettiView(isActive: $showConfetti)
            }
        }
    }
    return PreviewWrapper()
}
