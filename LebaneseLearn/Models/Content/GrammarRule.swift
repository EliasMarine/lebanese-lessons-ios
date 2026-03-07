import Foundation

struct GrammarRule: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let tag: String?
    let explanation: String
    let examples: [GrammarExample]?
    let table: GrammarTable?
}

struct GrammarExample: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
    let breakdown: String?
}

struct GrammarTable: Codable, Sendable {
    let headers: [String]
    let rows: [[String]]
}
