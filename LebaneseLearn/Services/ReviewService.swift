import Foundation

// MARK: - Review Service

@Observable
final class ReviewService: @unchecked Sendable {

    static let shared = ReviewService()

    private let api = APIService.shared

    private(set) var isLoading = false

    private init() {}

    // MARK: - SRS Stats

    /// Fetch the user's spaced repetition statistics.
    func fetchStats() async throws -> ReviewStats {
        isLoading = true
        defer { isLoading = false }

        return try await api.get("/api/srs/stats")
    }

    // MARK: - Due Cards

    /// Fetch all cards that are due for review.
    func fetchDueCards() async throws -> [SRSCard] {
        isLoading = true
        defer { isLoading = false }

        return try await api.get("/api/srs/due")
    }

    // MARK: - Submit Review

    /// Submit a review for a card with a quality rating.
    func submitReview(cardId: Int, rating: Int) async throws -> ReviewResponse {
        isLoading = true
        defer { isLoading = false }

        let body = ReviewRequest(cardId: cardId, rating: rating)
        return try await api.post("/api/srs/review", body: body)
    }

    // MARK: - Seed Phase

    /// Seed SRS cards from a lesson phase. Creates initial cards for all vocabulary in the phase.
    func seedPhase(phaseId: Int) async throws {
        isLoading = true
        defer { isLoading = false }

        let body = SeedPhaseRequest(phaseId: phaseId)
        let _: EmptyResponse = try await api.post("/api/srs/seed", body: body)
    }
}

// MARK: - Request / Response Types

private struct ReviewRequest: Codable, Sendable {
    let cardId: Int
    let rating: Int
}

private struct SeedPhaseRequest: Codable, Sendable {
    let phaseId: Int
}

/// Used for endpoints that return an empty or irrelevant JSON body.
private struct EmptyResponse: Codable, Sendable {}
