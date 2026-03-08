import Foundation
import SwiftData

@Model
final class XPEntry {
    var amount: Int
    var source: String
    var sourceId: String?
    var earnedAt: Date

    init(amount: Int, source: String, sourceId: String? = nil) {
        self.amount = amount
        self.source = source
        self.sourceId = sourceId
        self.earnedAt = .now
    }
}
