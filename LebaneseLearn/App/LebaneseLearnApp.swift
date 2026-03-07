import SwiftUI
import SwiftData

@main
struct LebaneseLearnApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            UserProfile.self,
            LessonProgressRecord.self,
            SRSCardRecord.self,
            ExerciseResultRecord.self,
            EarnedBadge.self,
            XPEntry.self,
            DailyActivityRecord.self,
            CompletedItemRecord.self,
            AIConversationRecord.self,
        ])
    }
}
