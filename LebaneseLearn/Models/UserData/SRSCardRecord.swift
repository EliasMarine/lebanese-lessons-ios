import Foundation
import SwiftData

@Model
final class SRSCardRecord {
    @Attribute(.unique) var vocabItemId: String
    var phaseId: Int
    var easeFactor: Double
    var interval: Int
    var repetitions: Int
    var nextReviewAt: Date
    var lastReviewedAt: Date?
    var createdAt: Date

    init(vocabItemId: String, phaseId: Int) {
        self.vocabItemId = vocabItemId
        self.phaseId = phaseId
        self.easeFactor = 2.5
        self.interval = 0
        self.repetitions = 0
        self.nextReviewAt = .now
        self.lastReviewedAt = nil
        self.createdAt = .now
    }
}
