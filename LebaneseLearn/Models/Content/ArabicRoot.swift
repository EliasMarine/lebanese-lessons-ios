import Foundation

struct ArabicRoot: Codable, Identifiable, Sendable {
    let id: String
    let root: String
    let rootLetters: String
    let meaning: String
    let words: [RootWord]
}

struct RootWord: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
    let form: String?
    let partOfSpeech: String
}
