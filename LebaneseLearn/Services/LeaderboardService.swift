import Foundation

// MARK: - Leaderboard Service

@Observable
final class LeaderboardService: @unchecked Sendable {

    static let shared = LeaderboardService()

    private let api = APIService.shared

    private(set) var isLoading = false

    private init() {}

    // MARK: - Leaderboard

    /// Fetch the global leaderboard rankings.
    func fetchLeaderboard() async throws -> [LeaderboardEntry] {
        isLoading = true
        defer { isLoading = false }

        let response: LeaderboardResponse = try await api.get("/api/leaderboard")
        return response.entries
    }

    // MARK: - Daily Challenges

    /// Fetch available daily challenges.
    func fetchDailyChallenges() async throws -> [DailyChallenge] {
        isLoading = true
        defer { isLoading = false }

        return try await api.get("/api/daily-challenge")
    }
}
