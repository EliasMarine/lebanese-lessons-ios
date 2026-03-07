import Foundation
import SwiftData

@Model
final class LessonProgressRecord {
    @Attribute(.unique) var uniqueKey: String
    var phaseId: Int
    var exerciseSetId: String
    var completed: Bool
    var bestScore: Int
    var attempts: Int
    var lastAttemptDate: Date

    init(phaseId: Int, exerciseSetId: String) {
        self.uniqueKey = "\(phaseId)-\(exerciseSetId)"
        self.phaseId = phaseId
        self.exerciseSetId = exerciseSetId
        self.completed = false
        self.bestScore = 0
        self.attempts = 0
        self.lastAttemptDate = .now
    }
}
