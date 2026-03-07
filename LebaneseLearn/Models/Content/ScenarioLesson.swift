import Foundation

struct ScenarioLesson: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let titleArabic: String
    let setting: String
    let branches: [ScenarioBranch]
    let comprehensionCheck: [ComprehensionQuestion]?
    let vocabSummary: [VocabSummaryItem]
}

struct ScenarioBranch: Codable, Identifiable, Sendable {
    let id: String
    let speaker: String
    let speakerRole: String
    let arabic: String
    let transliteration: String
    let english: String
    let choices: [ScenarioChoice]?
    let culturalTip: String?
}

struct ScenarioChoice: Codable, Sendable {
    let text: String
    let textArabic: String
    let textTransliteration: String
    let nextBranchId: String
    let culturalNote: String?
}

struct ComprehensionQuestion: Codable, Sendable {
    let question: String
    let options: [String]
    let correctIndex: Int
}

struct VocabSummaryItem: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
}
