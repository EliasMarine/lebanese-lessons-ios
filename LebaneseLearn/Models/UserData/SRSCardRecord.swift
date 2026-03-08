import Foundation
import SwiftData

@Model
final class SRSCardRecord {
    var vocabItemId: String = ""
    var phaseId: Int = 0
    var easeFactor: Double = 2.5
    var interval: Int = 0
    var repetitions: Int = 0
    var nextReviewAt: Date = Date()
    var lastReviewedAt: Date?
    var createdAt: Date = Date()

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
