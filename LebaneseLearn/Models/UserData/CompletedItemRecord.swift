import Foundation
import SwiftData

@Model
final class CompletedItemRecord {
    @Attribute(.unique) var uniqueKey: String
    var phaseId: Int
    var tab: String
    var itemId: String
    var completedAt: Date

    init(phaseId: Int, tab: String, itemId: String) {
        self.uniqueKey = "\(phaseId)-\(tab)-\(itemId)"
        self.phaseId = phaseId
        self.tab = tab
        self.itemId = itemId
        self.completedAt = .now
    }
}
