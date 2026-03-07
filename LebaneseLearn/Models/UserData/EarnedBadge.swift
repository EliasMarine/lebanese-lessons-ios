import Foundation
import SwiftData

@Model
final class EarnedBadge {
    @Attribute(.unique) var badgeId: String
    var earnedAt: Date

    init(badgeId: String) {
        self.badgeId = badgeId
        self.earnedAt = .now
    }
}
