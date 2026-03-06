import Foundation

// MARK: - SRS Card

struct SRSCard: Codable, Identifiable, Sendable {
    let id: Int
    let front: String
    let back: String
    let pronunciation: String?
    let category: String?
    var repetitions: Int
    var easeFactor: Double
    var interval: Int
    var dueAt: String
    var lastReviewedAt: String?
}

// MARK: - Review Stats

struct ReviewStats: Codable, Sendable {
    let dueNow: Int
    let totalCards: Int
    let reviewedToday: Int
    let mastered: Int
    let learning: Int
    let newCards: Int
    let streak: Int
    let avgEaseFactor: Double
    let retentionRate: Int
    let lastReviewAt: String?
}

// MARK: - Review Response

struct ReviewResponse: Codable, Sendable {
    let card: SRSCard
    let xpEarned: Int
    let newBadges: [Badge]?
}
