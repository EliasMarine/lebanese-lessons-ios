import Foundation

struct ExerciseSet: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let type: ExerciseContentType
    let questions: [QuizQuestion]?
    let fillBlanks: [FillBlankQuestion]?
    let matchingPairs: [MatchingPair]?
    let sentenceBuilderData: [SentenceBuilderItem]?

    enum ExerciseContentType: String, Codable, Sendable {
        case multipleChoice = "multiple-choice"
        case fillBlank = "fill-blank"
        case matching = "matching"
        case sentenceBuilder = "sentence-builder"
        case dictation = "dictation"
    }
}

struct QuizQuestion: Codable, Identifiable, Sendable {
    let id: String
    let prompt: String
    let promptArabic: String?
    let options: [String]
    let correctIndex: Int
    let explanation: String?
}

struct FillBlankQuestion: Codable, Identifiable, Sendable {
    let id: String
    let sentence: String
    let blank: String
    let answer: String
    let acceptableAnswers: [String]?
    let hint: String?
}

struct MatchingPair: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
}

struct SentenceBuilderItem: Codable, Sendable {
    let words: [String]
    let correctOrder: [Int]
    let english: String
}
