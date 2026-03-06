import SwiftUI

// MARK: - Design System

/// Centralized design tokens matching the web app at arabicisbeautiful.com.
enum Theme {

    // MARK: Brand Colors

    static let brand      = Color(hex: "#E94560")
    static let success    = Color(hex: "#00B894")
    static let warning    = Color(hex: "#FDCB6E")
    static let info       = Color(hex: "#74B9FF")
    static let xpPurple   = Color(hex: "#A29BFE")

    // MARK: Dim / Badge Background Variants

    static let brandDim   = brand.opacity(0.15)
    static let successDim = success.opacity(0.15)
    static let warningDim = warning.opacity(0.15)
    static let infoDim    = info.opacity(0.15)
    static let xpDim      = xpPurple.opacity(0.15)

    // MARK: Background Colors

    /// Main page background.
    static let bgMain = Color("bgMain", bundle: nil)

    /// Card / elevated surface background.
    static let bgCard = Color("bgCard", bundle: nil)

    /// Secondary surface (e.g. input fields).
    static let bgSurface = Color("bgSurface", bundle: nil)

    // MARK: Adaptive Background Helpers (fallback when color assets are missing)

    static func bgMainAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(hex: "#0F0F1A")
            : Color(hex: "#F8F9FA")
    }

    static func bgCardAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(hex: "#1A1A2E")
            : Color.white
    }

    static func bgSurfaceAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(hex: "#16213E")
            : Color(hex: "#F1F3F5")
    }

    // MARK: Text Colors

    static func textPrimary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white
            : Color(hex: "#2D3436")
    }

    static func textSecondary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(hex: "#B2BEC3")
            : Color(hex: "#636E72")
    }

    // MARK: Border Colors

    static func border(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.06)
    }

    // MARK: Shadows

    static func cardShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.black.opacity(0.4)
            : Color.black.opacity(0.06)
    }

    // MARK: Corner Radii

    static let cardRadius: CGFloat = 16
    static let buttonRadius: CGFloat = 12
    static let badgeRadius: CGFloat = 8
    static let inputRadius: CGFloat = 10

    // MARK: Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
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
