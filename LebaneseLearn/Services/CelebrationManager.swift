import SwiftUI

/// Manages XP popups, confetti bursts, and star ratings app-wide.
/// Injected via `.environment()` on MainTabView so any child view can trigger celebrations.
@Observable
@MainActor
final class CelebrationManager {
    var xpPopupAmount: Int?
    var showConfetti: Bool = false
    var starRating: Int?

    /// Trigger a floating "+X XP" popup.
    func celebrateXP(_ amount: Int) {
        xpPopupAmount = amount
    }

    /// Trigger confetti + star rating based on exercise accuracy.
    func celebrateCompletion(accuracy: Double) {
        showConfetti = true
        starRating = StarRatingView.starsForAccuracy(accuracy)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.starRating = nil
        }
    }
}
