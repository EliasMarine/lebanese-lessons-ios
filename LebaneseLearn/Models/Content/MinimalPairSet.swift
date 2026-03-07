import Foundation

struct MinimalPairSet: Codable, Identifiable, Sendable {
    let id: String
    let sound1: SoundDescription
    let sound2: SoundDescription
    let tip: String
    let examples: [MinimalPairExample]
}

struct SoundDescription: Codable, Sendable {
    let letter: String
    let name: String
    let description: String
}

struct MinimalPairExample: Codable, Sendable {
    let word1: WordEntry
    let word2: WordEntry
}

struct WordEntry: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
}
