import Foundation

struct Dialogue: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let context: String?
    let lines: [DialogueLine]
}

struct DialogueLine: Codable, Sendable {
    let speaker: String
    let speakerRole: String
    let arabic: String
    let transliteration: String
    let english: String
    let audioFile: String?
}
