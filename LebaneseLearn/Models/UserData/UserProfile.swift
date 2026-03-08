import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var totalXP: Int
    var level: Int
    var levelTitle: String
    var currentXPInLevel: Int
    var xpNeededForLevel: Int
    var streak: Int
    var longestStreak: Int
    var studyGoalMinutes: Int
    var lastStudyDate: Date?
    var hasCompletedOnboarding: Bool
    var createdAt: Date

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
