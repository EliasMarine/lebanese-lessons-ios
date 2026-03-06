import Foundation

// MARK: - Badge

struct Badge: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let xpReward: Int
    let earnedAt: String?

    var isEarned: Bool { earnedAt != nil }
}

// MARK: - Daily Challenge

struct DailyChallenge: Codable, Identifiable, Sendable {
    let id: String
    let type: String
    let title: String
    let description: String
    let target: Int
    let current: Int
    let xpReward: Int
    let completed: Bool

    var isCompleted: Bool { completed }

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }

    var icon: String {
        switch type {
        case "review":  return "rectangle.stack.fill"
        case "learn":   return "sparkles"
        case "lesson":  return "book.fill"
        case "streak":  return "flame.fill"
        default:        return "star.fill"
        }
    }
}
