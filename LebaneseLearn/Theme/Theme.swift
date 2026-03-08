import SwiftUI

// MARK: - Design System

/// Centralized design tokens — Liquid Glass with vibrant popping colors.
enum Theme {

    // MARK: Brand Colors (Vibrant & Popping)

    static let brand       = Color(hex: "#E94560")   // Coral Red
    static let electricBlue = Color(hex: "#00D2FF")   // Electric Blue
    static let vividGreen  = Color(hex: "#00E676")    // Vivid Green
    static let hotPink     = Color(hex: "#FF1493")    // Hot Pink
    static let goldenYellow = Color(hex: "#FFD600")   // Golden Yellow
    static let brightPurple = Color(hex: "#B388FF")   // Bright Purple
    static let sunsetOrange = Color(hex: "#FF6D00")   // Sunset Orange

    // Legacy aliases
    static let success     = vividGreen
    static let warning     = goldenYellow
    static let info        = electricBlue
    static let xpPurple    = brightPurple

    // MARK: Dim / Badge Background Variants

    static let brandDim    = brand.opacity(0.15)
    static let successDim  = success.opacity(0.15)
    static let warningDim  = warning.opacity(0.15)
    static let infoDim     = info.opacity(0.15)
    static let xpDim       = xpPurple.opacity(0.15)

    // MARK: Phase Gradients

    static let phaseGradients: [Int: [Color]] = [
        1: [brand, hotPink],
        2: [sunsetOrange, goldenYellow],
        3: [electricBlue, brightPurple],
        4: [vividGreen, electricBlue],
        5: [brightPurple, hotPink],
        6: [goldenYellow, sunsetOrange],
    ]

    static func phaseGradient(for phaseId: Int) -> LinearGradient {
        let colors = phaseGradients[phaseId] ?? [brand, hotPink]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // MARK: Corner Radii

    static let cardRadius: CGFloat = 20
    static let buttonRadius: CGFloat = 14
    static let badgeRadius: CGFloat = 10
    static let inputRadius: CGFloat = 12

    // MARK: Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
}

// MARK: - Liquid Glass View Modifiers

extension View {

    /// Standard glass card with rounded corners.
    func glassCard() -> some View {
        self
            .padding(Theme.spacingMD)
            .glassEffect(in: .rect(cornerRadius: Theme.cardRadius))
    }

    /// Tinted glass card with a brand color accent.
    func glassCard(tint: Color) -> some View {
        self
            .padding(Theme.spacingMD)
            .glassEffect(.regular.tint(tint), in: .rect(cornerRadius: Theme.cardRadius))
    }

    /// Interactive glass button style.
    func glassButton() -> some View {
        self
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingSM)
            .glassEffect(.regular.interactive(), in: .capsule)
    }

    /// Prominent glass button with tint.
    func glassButtonProminent(tint: Color = Theme.brand) -> some View {
        self
            .padding(.horizontal, Theme.spacingLG)
            .padding(.vertical, Theme.spacingMD)
            .glassEffect(.regular.tint(tint).interactive(), in: .capsule)
    }

    /// XP badge pill.
    func xpBadge() -> some View {
        self
            .font(.nunito(13, weight: .bold))
            .foregroundStyle(Theme.xpPurple)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .glassEffect(.regular.tint(Theme.xpPurple), in: .capsule)
    }

    /// Streak flame badge.
    func streakBadge() -> some View {
        self
            .font(.nunito(13, weight: .bold))
            .foregroundStyle(Theme.sunsetOrange)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .glassEffect(.regular.tint(Theme.sunsetOrange), in: .capsule)
    }
}

// MARK: - Font Helpers

extension Font {

    /// Returns Nunito if available, otherwise the rounded system design.
    static func nunito(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .bold:       name = "Nunito-Bold"
        case .semibold:   name = "Nunito-SemiBold"
        case .medium:     name = "Nunito-Medium"
        case .light:      name = "Nunito-Light"
        default:          name = "Nunito-Regular"
        }

        if UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: weight, design: .rounded)
    }

    // Convenience presets
    static let headingLarge  = nunito(28, weight: .bold)
    static let headingMedium = nunito(22, weight: .bold)
    static let headingSmall  = nunito(18, weight: .semibold)
    static let bodyLarge     = nunito(16, weight: .regular)
    static let bodyMedium    = nunito(14, weight: .regular)
    static let bodySmall     = nunito(12, weight: .regular)
    static let caption       = nunito(11, weight: .medium)
}
