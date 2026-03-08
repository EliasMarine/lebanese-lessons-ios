import Foundation
import SwiftData

@Model
final class EarnedBadge {
    var badgeId: String = ""
    var earnedAt: Date = Date()

    init(badgeId: String) {
        self.badgeId = badgeId
        self.earnedAt = .now
    }
}
