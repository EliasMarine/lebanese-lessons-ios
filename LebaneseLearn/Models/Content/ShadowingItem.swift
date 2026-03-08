import Foundation

struct ShadowingItem: Codable, Identifiable, Sendable {
    let id: String
    let arabic: String
    let transliteration: String
    let english: String
    let audioFile: String?
    let steps: [String]
}
