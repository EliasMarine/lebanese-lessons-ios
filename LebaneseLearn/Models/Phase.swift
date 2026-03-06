import Foundation

// MARK: - Phase

struct Phase: Codable, Identifiable, Sendable {
    let id: Int
    let name: String
    let subtitle: String
    let description: String
    let lessons: [Lesson]?
    var progress: Double?
}
