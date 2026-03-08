import SwiftUI

/// Displays 1-3 stars based on accuracy, each bouncing in sequentially.
struct StarRatingView: View {
    let stars: Int
    let maxStars: Int = 3

    @State private var visibleStars: Int = 0

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<maxStars, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(index < stars ? Theme.duoYellow : Color.gray.opacity(0.3))
                    .shadow(color: index < stars ? Theme.duoYellow.opacity(0.4) : .clear, radius: 4, x: 0, y: 2)
                    .scaleEffect(index < visibleStars ? 1.0 : 0.0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.5)
                        .delay(Double(index) * 0.2),
                        value: visibleStars
                    )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                visibleStars = maxStars
            }
        }
    }

    /// Create stars from exercise accuracy percentage.
    static func starsForAccuracy(_ accuracy: Double) -> Int {
        if accuracy >= 0.9 { return 3 }
        if accuracy >= 0.7 { return 2 }
        if accuracy >= 0.5 { return 1 }
        return 0
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        StarRatingView(stars: 3)
        StarRatingView(stars: 2)
        StarRatingView(stars: 1)
        StarRatingView(stars: 0)
    }
    .padding()
}
