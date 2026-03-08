import Foundation

struct VerbConjugation: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let verb: String
    let verbArabic: String
    let meaning: String
    let pastTense: ConjugationSet
    let presentTense: ConjugationSet
    let imperative: ImperativeSet?
    let exampleSentences: [VerbExample]
}

struct ConjugationSet: Codable, Sendable {
    let ana: String
    let enta: String
    let ente: String
    let huwwe: String
    let hiyye: String
    let ne7na: String
    let ento: String
    let henne: String
}

struct ImperativeSet: Codable, Sendable {
    let singularM: String
    let singularF: String
    let plural: String

    enum CodingKeys: String, CodingKey {
        case singularM = "singular_m"
        case singularF = "singular_f"
        case plural
    }
}

struct VerbExample: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
}
