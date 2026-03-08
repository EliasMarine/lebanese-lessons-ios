import Foundation

struct VocabItem: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let arabic: String
    let transliteration: String
    let english: String
    let partOfSpeech: String?
    let audioFile: String?
    let category: String?
    let notes: String?
    let exampleSentence: ExampleSentence?

    struct ExampleSentence: Codable, Sendable {
        let arabic: String
        let transliteration: String
        let english: String
    }
}
