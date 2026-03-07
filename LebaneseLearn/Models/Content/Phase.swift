import Foundation

struct Phase: Codable, Identifiable, Sendable {
    let id: Int
    let slug: String
    let title: String
    let titleArabic: String
    let subtitle: String
    let description: String
    let estimatedWeeks: String
    let heroGradient: String
    let heroArabicWatermark: String
}
