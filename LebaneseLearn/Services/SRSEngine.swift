import Foundation
import SwiftData

struct SRSEngine {
    static func processReview(card: SRSCardRecord, rating: Int) {
        let q = Double(max(0, min(rating, 5)))

        if q < 3 {
            card.repetitions = 0
            card.interval = 0
        } else {
            switch card.repetitions {
            case 0: card.interval = 1
            case 1: card.interval = 6
            default: card.interval = Int(Double(card.interval) * card.easeFactor)
            }
            card.repetitions += 1
        }

        card.easeFactor = max(1.3, card.easeFactor + 0.1 - (5.0 - q) * (0.08 + (5.0 - q) * 0.02))
        card.lastReviewedAt = .now
        card.nextReviewAt = Calendar.current.date(byAdding: .day, value: max(1, card.interval), to: .now) ?? .now
    }

    static func seedCards(from vocab: [VocabItem], phaseId: Int, context: ModelContext) {
        for item in vocab {
            let itemId = item.id
            let descriptor = FetchDescriptor<SRSCardRecord>(
                predicate: #Predicate { $0.vocabItemId == itemId }
            )
            let existing = (try? context.fetchCount(descriptor)) ?? 0
            if existing == 0 {
                let card = SRSCardRecord(vocabItemId: item.id, phaseId: phaseId)
                context.insert(card)
            }
        }
        try? context.save()
    }
}
