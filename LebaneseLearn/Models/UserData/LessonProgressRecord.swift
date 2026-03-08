import Foundation
import SwiftData

@Model
final class LessonProgressRecord {
    var uniqueKey: String = ""
    var phaseId: Int = 0
    var exerciseSetId: String = ""
    var completed: Bool = false
    var bestScore: Int = 0
    var attempts: Int = 0
    var lastAttemptDate: Date = Date()

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
