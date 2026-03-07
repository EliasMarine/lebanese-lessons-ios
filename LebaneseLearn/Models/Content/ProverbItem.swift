import Foundation

struct ProverbItem: Codable, Identifiable, Sendable {
    let id: String
    let arabic: String
    let transliteration: String
    let english: String
    let meaning: String
}
