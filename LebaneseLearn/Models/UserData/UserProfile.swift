import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String = ""
    var totalXP: Int = 0
    var level: Int = 1
    var levelTitle: String = "Beginner"
    var currentXPInLevel: Int = 0
    var xpNeededForLevel: Int = 200
    var streak: Int = 0
    var longestStreak: Int = 0
    var studyGoalMinutes: Int = 10
    var lastStudyDate: Date?
    var hasCompletedOnboarding: Bool = false
    var createdAt: Date = Date()

    init(
        name: String,
        totalXP: Int = 0,
        level: Int = 1,
        levelTitle: String = "Beginner",
        currentXPInLevel: Int = 0,
        xpNeededForLevel: Int = 200,
        streak: Int = 0,
        longestStreak: Int = 0,
        studyGoalMinutes: Int = 10,
        hasCompletedOnboarding: Bool = false
    ) {
        self.name = name
        self.totalXP = totalXP
        self.level = level
        self.levelTitle = levelTitle
        self.currentXPInLevel = currentXPInLevel
        self.xpNeededForLevel = xpNeededForLevel
        self.streak = streak
        self.longestStreak = longestStreak
        self.studyGoalMinutes = studyGoalMinutes
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.lastStudyDate = nil
        self.createdAt = .now
    }
}
