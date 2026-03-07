import Foundation

struct MSAComparison: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let category: String
    let items: [MSAComparisonItem]
}

struct MSAComparisonItem: Codable, Sendable {
    let concept: String
    let msa: LanguageVariant
    let lebanese: LanguageVariant
    let notes: String
}

struct LanguageVariant: Codable, Sendable {
    let arabic: String
    let transliteration: String
}
