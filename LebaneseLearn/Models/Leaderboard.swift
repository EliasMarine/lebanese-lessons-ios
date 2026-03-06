import Foundation

// MARK: - Leaderboard Entry

struct LeaderboardEntry: Codable, Identifiable, Sendable {
    let id: String
    let rank: Int
    let name: String
    let totalXP: Int
    let level: Int
    let levelTitle: String
    let levelProgress: LevelProgress
    let isCurrentUser: Bool
}

// MARK: - Leaderboard Response

struct LeaderboardResponse: Codable, Sendable {
    let entries: [LeaderboardEntry]
    let currentUserRank: Int?
}
