import Foundation
import CloudKit

@Observable
final class CloudKitService {
    static let shared = CloudKitService()

    struct LeaderboardEntry: Identifiable, Sendable {
        let id: String
        let rank: Int
        let name: String
        let totalXP: Int
        let level: Int
        let levelTitle: String
        var isCurrentUser: Bool = false
    }

    private(set) var entries: [LeaderboardEntry] = []
    private(set) var currentUserRank: Int?
    private(set) var isLoading = false

    private let container = CKContainer.default()
    private var database: CKDatabase { container.publicCloudDatabase }

    func fetchLeaderboard() async {
        isLoading = true
        defer { isLoading = false }

        let query = CKQuery(recordType: "LeaderboardEntry", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "totalXP", ascending: false)]

        do {
            let (results, _) = try await database.records(matching: query, resultsLimit: 50)
            var ranked: [LeaderboardEntry] = []
            var rank = 1

            for (_, result) in results {
                if let record = try? result.get() {
                    ranked.append(LeaderboardEntry(
                        id: record.recordID.recordName,
                        rank: rank,
                        name: record["userName"] as? String ?? "Unknown",
                        totalXP: record["totalXP"] as? Int ?? 0,
                        level: record["level"] as? Int ?? 1,
                        levelTitle: record["levelTitle"] as? String ?? "Beginner"
                    ))
                    rank += 1
                }
            }
            entries = ranked
        } catch {
            print("CloudKit fetch error: \(error)")
        }
    }

    func updateScore(profile: UserProfile) async {
        let recordID = CKRecord.ID(recordName: "user-\(profile.name.lowercased().replacingOccurrences(of: " ", with: "-"))")
        let record: CKRecord

        do {
            record = try await database.record(for: recordID)
        } catch {
            record = CKRecord(recordType: "LeaderboardEntry", recordID: recordID)
        }

        record["userName"] = profile.name
        record["totalXP"] = profile.totalXP
        record["level"] = profile.level
        record["levelTitle"] = profile.levelTitle

        do {
            try await database.save(record)
        } catch {
            print("CloudKit save error: \(error)")
        }
    }
}
