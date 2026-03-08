import Foundation
import SwiftData

@Model
final class XPEntry {
    var amount: Int = 0
    var source: String = ""
    var sourceId: String?
    var earnedAt: Date = Date()

    init(amount: Int, source: String, sourceId: String? = nil) {
        self.amount = amount
        self.source = source
        self.sourceId = sourceId
        self.earnedAt = .now
    }
}
