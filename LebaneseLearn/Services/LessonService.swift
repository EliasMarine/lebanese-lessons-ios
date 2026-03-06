import Foundation

// MARK: - Exercise Result Response

struct ExerciseResultResponse: Codable, Sendable {
    let xpEarned: Int
    let accuracy: Int
    let newBadges: [Badge]?
    let streakBonus: Double?
}

// MARK: - Lesson Service

@Observable
final class LessonService: @unchecked Sendable {

    static let shared = LessonService()

    private let api = APIService.shared

    private(set) var isLoading = false

    private init() {}

    // MARK: - Phases

    /// Fetch all curriculum phases.
    func fetchPhases() async throws -> [Phase] {
        isLoading = true
        defer { isLoading = false }

        return try await api.get("/api/phases")
    }

    // MARK: - Lessons

    /// Fetch all lessons within a specific phase.
    func fetchLessons(phaseId: Int) async throws -> [Lesson] {
        isLoading = true
        defer { isLoading = false }

        return try await api.get("/api/phases/\(phaseId)/lessons")
    }

    // MARK: - Exercises

    /// Fetch all exercises for a specific lesson.
    func fetchExercises(lessonId: Int) async throws -> [Exercise] {
        isLoading = true
        defer { isLoading = false }

        return try await api.get("/api/lessons/\(lessonId)/exercises")
    }

    // MARK: - Submit Result

    /// Submit the result of a completed exercise.
    func submitResult(result: ExerciseResult) async throws -> ExerciseResultResponse {
        isLoading = true
        defer { isLoading = false }

        return try await api.post("/api/exercises/result", body: result)
    }
}
