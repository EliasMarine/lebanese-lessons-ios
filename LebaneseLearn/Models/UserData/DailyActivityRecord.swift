import Foundation
import SwiftData

@Model
final class DailyActivityRecord {
    @Attribute(.unique) var date: String
    var minutesStudied: Int
    var cardsReviewed: Int
    var exercisesCompleted: Int

    init(date: String) {
        self.date = date
        self.minutesStudied = 0
        self.cardsReviewed = 0
        self.exercisesCompleted = 0
    }
}
