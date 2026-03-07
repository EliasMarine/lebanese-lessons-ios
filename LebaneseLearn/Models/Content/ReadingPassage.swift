import Foundation

struct ReadingPassage: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let titleArabic: String
    let level: String
    let arabic: String
    let transliteration: String
    let english: String
    let vocabHighlights: [VocabHighlight]?
    let comprehensionQuestions: [ReadingQuestion]?
}

struct VocabHighlight: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
}

struct ReadingQuestion: Codable, Sendable {
    let question: String
    let answer: String
}
