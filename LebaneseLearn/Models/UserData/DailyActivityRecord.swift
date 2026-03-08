import Foundation
import SwiftData

@Model
final class DailyActivityRecord {
    var date: String = ""
    var minutesStudied: Int = 0
    var cardsReviewed: Int = 0
    var exercisesCompleted: Int = 0

    init(date: String) {
        self.date = date
        self.minutesStudied = 0
        self.cardsReviewed = 0
        self.exercisesCompleted = 0
    }
}
