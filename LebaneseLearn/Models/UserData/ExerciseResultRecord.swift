import Foundation
import SwiftData

@Model
final class ExerciseResultRecord {
    var phaseId: Int
    var exerciseSetId: String
    var exerciseType: String
    var score: Int
    var totalQuestions: Int
    var correctAnswers: Int
    var timeSpentSeconds: Int
    var completedAt: Date

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
