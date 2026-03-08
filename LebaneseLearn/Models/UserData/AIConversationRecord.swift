import Foundation
import SwiftData

@Model
final class AIConversationRecord {
    var phaseId: Int
    var title: String
    var messagesJSON: String
    var createdAt: Date
    var updatedAt: Date

    init(phaseId: Int, title: String, messagesJSON: String = "[]") {
        self.phaseId = phaseId
        self.title = title
        self.messagesJSON = messagesJSON
        self.createdAt = .now
        self.updatedAt = .now
    }
}
