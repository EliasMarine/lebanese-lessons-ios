import SwiftUI

// MARK: - Design System

/// Centralized design tokens — Bold & Playful Duolingo-inspired design.
enum Theme {

    // MARK: - Primary Colors (Duolingo-Inspired)

    static let duoGreen     = Color(hex: "#58CC02")   // Primary / Brand / Success
    static let duoOrange    = Color(hex: "#FF9600")   // Streaks / Warnings
    static let duoBlue      = Color(hex: "#1CB0F6")   // Info / Learning
    static let duoRed       = Color(hex: "#FF4B4B")   // Errors / Danger
    static let duoYellow    = Color(hex: "#FFC800")   // Stars / Achievements
    static let duoPurple    = Color(hex: "#CE82FF")   // XP / Levels

    // MARK: - Darker Pressed / Shadow Variants

    static let duoGreenDark  = Color(hex: "#46A302")
    static let duoBlueDark   = Color(hex: "#1899D6")
    static let duoRedDark    = Color(hex: "#EA2B2B")
    static let duoOrangeDark = Color(hex: "#DB8200")
    static let duoYellowDark = Color(hex: "#DBA800")
    static let duoPurpleDark = Color(hex: "#A855D6")

    // MARK: - Semantic Aliases

    static let brand       = duoGreen
    static let success     = duoGreen
    static let warning     = duoOrange
    static let info        = duoBlue
    static let danger      = duoRed
    static let xpPurple    = duoPurple
    static let streakColor = duoOrange

    // Legacy aliases (for existing code compatibility)
    static let electricBlue  = duoBlue
    static let vividGreen    = duoGreen
    static let hotPink       = Color(hex: "#FF86D0")
    static let goldenYellow  = duoYellow
    static let brightPurple  = duoPurple
    static let sunsetOrange  = duoOrange

    // MARK: - Surface Colors

    static let background  = Color(uiColor: .systemBackground)
    static let surface     = Color(hex: "#F7F7F7")
    static let cardBg      = Color.white
    static let textPrimary = Color(hex: "#4B4B4B")
    static let textMuted   = Color(hex: "#AFAFAF")
    static let borderLight = Color.gray.opacity(0.15)

    // MARK: - Dim / Badge Background Variants

    static let brandDim    = brand.opacity(0.15)
    static let successDim  = success.opacity(0.15)
    static let warningDim  = warning.opacity(0.15)
    static let infoDim     = info.opacity(0.15)
    static let xpDim       = xpPurple.opacity(0.15)

    // MARK: - Phase Gradients

    static let phaseGradients: [Int: [Color]] = [
        1: [duoGreen, Color(hex: "#89E219")],
        2: [duoOrange, duoYellow],
        3: [duoBlue, duoPurple],
        4: [Color(hex: "#00CD9C"), duoBlue],
        5: [duoPurple, Color(hex: "#FF86D0")],
        6: [duoYellow, duoOrange],
    ]

    static func phaseGradient(for phaseId: Int) -> LinearGradient {
        let colors = phaseGradients[phaseId] ?? [brand, Color(hex: "#89E219")]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // MARK: - Corner Radii (Chunky)

    static let cardRadius: CGFloat   = 16
    static let buttonRadius: CGFloat = 16
    static let badgeRadius: CGFloat  = 12
    static let inputRadius: CGFloat  = 14

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Borders & Shadows

    static let cardBorderWidth: CGFloat   = 2.5
    static let buttonBorderWidth: CGFloat = 3
    static let cardShadowY: CGFloat       = 4
    static let buttonShadowY: CGFloat     = 5
}

// MARK: - Bold Card & Button View Modifiers

extension View {

    /// Solid card with white background, light border, and chunky bottom shadow.
    func duoCard() -> some View {
        self
            .padding(Theme.spacingMD)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .stroke(Theme.borderLight, lineWidth: Theme.cardBorderWidth)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 0, x: 0, y: Theme.cardShadowY)
    }

    /// Tinted card with colored tint background, colored border, and colored shadow.
    func duoCard(tint: Color) -> some View {
        self
            .padding(Theme.spacingMD)
            .background(tint.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .stroke(tint.opacity(0.3), lineWidth: Theme.cardBorderWidth)
            )
            .shadow(color: tint.opacity(0.15), radius: 0, x: 0, y: Theme.cardShadowY)
    }

    /// Simple outline button with surface background.
    func duoButton() -> some View {
        self
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingSM)
            .background(Theme.surface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 2))
    }

    /// Bold prominent button — solid color capsule with chunky shadow.
    func duoButtonProminent(tint: Color = Theme.brand) -> some View {
        self
            .padding(.horizontal, Theme.spacingLG)
            .padding(.vertical, Theme.spacingMD)
            .background(tint)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .shadow(color: tint.opacity(0.35), radius: 0, x: 0, y: Theme.buttonShadowY)
    }

    /// Small chip / pill for tags and categories.
    func duoChip(tint: Color) -> some View {
        self
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(tint.opacity(0.3), lineWidth: 1.5))
    }

    /// Selectable tile for exercise options, matching, etc.
    func duoTile(isSelected: Bool = false, tint: Color = Theme.brand) -> some View {
        self
            .padding(Theme.spacingMD)
            .background(isSelected ? tint.opacity(0.08) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.buttonRadius, style: .continuous)
                    .stroke(isSelected ? tint : Color.gray.opacity(0.2), lineWidth: isSelected ? 2.5 : 2)
            )
            .shadow(color: isSelected ? tint.opacity(0.15) : Color.black.opacity(0.05), radius: 0, x: 0, y: 3)
    }

    /// Text field / input styling.
    func duoInput() -> some View {
        self
            .padding(Theme.spacingSM)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
            )
    }

    /// Tinted input (for correct / incorrect states).
    func duoInput(tint: Color) -> some View {
        self
            .padding(Theme.spacingSM)
            .background(tint.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous)
                    .stroke(tint.opacity(0.5), lineWidth: 2.5)
            )
    }

    /// XP badge pill.
    func xpBadge() -> some View {
        self
            .font(.nunito(13, weight: .bold))
            .foregroundStyle(Theme.xpPurple)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Theme.xpPurple.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Theme.xpPurple.opacity(0.3), lineWidth: 1.5))
    }

    /// Streak flame badge.
    func streakBadge() -> some View {
        self
            .font(.nunito(13, weight: .bold))
            .foregroundStyle(Theme.streakColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Theme.streakColor.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Theme.streakColor.opacity(0.3), lineWidth: 1.5))
    }

    // MARK: - Deprecated Glass Aliases (remove after migration)

    /// Deprecated: use duoCard() instead.
    func glassCard() -> some View { duoCard() }

    /// Deprecated: use duoCard(tint:) instead.
    func glassCard(tint: Color) -> some View { duoCard(tint: tint) }

    /// Deprecated: use duoButton() instead.
    func glassButton() -> some View { duoButton() }

    /// Deprecated: use duoButtonProminent(tint:) instead.
    func glassButtonProminent(tint: Color = Theme.brand) -> some View {
        duoButtonProminent(tint: tint)
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
