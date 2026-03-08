import Foundation
import SwiftData

@Model
final class ExerciseResultRecord {
    var phaseId: Int = 0
    var exerciseSetId: String = ""
    var exerciseType: String = ""
    var score: Int = 0
    var totalQuestions: Int = 0
    var correctAnswers: Int = 0
    var timeSpentSeconds: Int = 0
    var completedAt: Date = Date()

    init(
        phaseId: Int,
        exerciseSetId: String,
        exerciseType: String,
        score: Int,
        totalQuestions: Int,
        correctAnswers: Int,
        timeSpentSeconds: Int
    ) {
        self.phaseId = phaseId
        self.exerciseSetId = exerciseSetId
        self.exerciseType = exerciseType
        self.score = score
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.timeSpentSeconds = timeSpentSeconds
        self.completedAt = .now
    }
}
