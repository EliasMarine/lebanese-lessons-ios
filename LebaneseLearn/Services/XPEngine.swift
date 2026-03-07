import Foundation
import SwiftData

struct XPEngine {
    struct LevelInfo {
        let level: Int
        let title: String
        let xpRequired: Int
    }

    static let levels: [LevelInfo] = [
        LevelInfo(level: 1, title: "Beginner", xpRequired: 0),
        LevelInfo(level: 2, title: "Explorer", xpRequired: 200),
        LevelInfo(level: 3, title: "Apprentice", xpRequired: 500),
        LevelInfo(level: 4, title: "Speaker", xpRequired: 1000),
        LevelInfo(level: 5, title: "Conversationalist", xpRequired: 1800),
        LevelInfo(level: 6, title: "Storyteller", xpRequired: 3000),
        LevelInfo(level: 7, title: "Fluent", xpRequired: 5000),
        LevelInfo(level: 8, title: "Native-like", xpRequired: 8000),
        LevelInfo(level: 9, title: "Master", xpRequired: 12000),
        LevelInfo(level: 10, title: "Legend", xpRequired: 20000),
    ]

    static func awardXP(
        amount: Int,
        source: String,
        sourceId: String? = nil,
        profile: UserProfile,
        context: ModelContext
    ) {
        let entry = XPEntry(amount: amount, source: source, sourceId: sourceId)
        context.insert(entry)

        profile.totalXP += amount

        let newLevel = levels.last(where: { $0.xpRequired <= profile.totalXP }) ?? levels[0]
        profile.level = newLevel.level
        profile.levelTitle = newLevel.title

        let nextLevel = levels.first(where: { $0.xpRequired > profile.totalXP })
        if let next = nextLevel {
            let currentLevelXP = newLevel.xpRequired
            profile.currentXPInLevel = profile.totalXP - currentLevelXP
            profile.xpNeededForLevel = next.xpRequired - currentLevelXP
        } else {
            profile.currentXPInLevel = profile.totalXP
            profile.xpNeededForLevel = profile.totalXP
        }

        try? context.save()
    }

    static func updateStreak(profile: UserProfile) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        if let lastStudy = profile.lastStudyDate {
            let lastDay = calendar.startOfDay(for: lastStudy)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if diff == 1 {
                profile.streak += 1
                profile.longestStreak = max(profile.longestStreak, profile.streak)
            } else if diff > 1 {
                profile.streak = 1
            }
        } else {
            profile.streak = 1
        }
        profile.lastStudyDate = .now
    }
}
