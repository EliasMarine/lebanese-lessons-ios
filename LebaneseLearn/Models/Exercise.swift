import Foundation

// MARK: - Lesson

struct Lesson: Codable, Identifiable, Sendable {
    let id: Int
    let phaseId: Int
    let slug: String
    let title: String
    let description: String
    let order: Int
    var progress: LessonProgress?
}

// MARK: - Lesson Progress

struct LessonProgress: Codable, Sendable {
    let completed: Bool
    let bestScore: Int?
    let attempts: Int
}

// MARK: - Exercise

struct Exercise: Codable, Identifiable, Sendable {
    let id: Int
    let lessonId: Int
    let type: ExerciseType
    let prompt: String
    let promptAr: String?
    let correctAnswer: String
    let options: [String]?
    let audioUrl: String?
    let order: Int
}

// MARK: - Exercise Type

enum ExerciseType: String, Codable, Sendable {
    case multipleChoice = "multiple_choice"
    case fillBlank      = "fill_blank"
    case translate      = "translate"
    case listening      = "listening"
    case matching       = "matching"
}

// MARK: - Results

struct ExerciseResult: Codable, Sendable {
    let lessonId: Int
    let score: Int
    let totalQuestions: Int
    let accuracy: Int
    let answers: [AnswerResult]
}

struct AnswerResult: Codable, Sendable {
    let exerciseId: Int
    let correct: Bool
    let userAnswer: String
    let timeSpent: Int
}
