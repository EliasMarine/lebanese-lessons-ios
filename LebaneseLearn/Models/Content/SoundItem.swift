import Foundation

struct SoundItem: Codable, Sendable {
    let letter: String
    let name: String
    let description: String
    let exampleArabic: String?
    let exampleTransliteration: String?
    let exampleEnglish: String?
}

struct LetterForm: Codable, Sendable {
    let letter: String
    let name: String
    let isolated: String
    let initial: String
    let medial: String
    let final: String
}
