import Foundation

struct CultureNote: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let content: String
    let items: [CultureItem]?
}

struct CultureItem: Codable, Sendable {
    let label: String
    let value: String
    let origin: String?
}
