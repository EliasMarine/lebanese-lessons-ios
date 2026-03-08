import Foundation
import SwiftData

@Model
final class AIConversationRecord {
    var phaseId: Int = 0
    var title: String = ""
    var messagesJSON: String = "[]"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(phaseId: Int, title: String, messagesJSON: String = "[]") {
        self.phaseId = phaseId
        self.title = title
        self.messagesJSON = messagesJSON
        self.createdAt = .now
        self.updatedAt = .now
    }
}
