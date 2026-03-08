import Foundation

struct PlacementQuestion: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let prompt: String
    let promptArabic: String?
    let options: [String]
    let correctIndex: Int
    let explanation: String
}
