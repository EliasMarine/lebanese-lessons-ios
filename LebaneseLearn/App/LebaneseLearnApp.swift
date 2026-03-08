import SwiftUI
import SwiftData

@main
struct LebaneseLearnApp: App {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
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
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none  // Local-only — we use CloudKit manually for leaderboards
        )
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
