import Foundation

struct JournalPrompt: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let arabic: String
    let transliteration: String
    let english: String
    let exampleResponse: String?
}
