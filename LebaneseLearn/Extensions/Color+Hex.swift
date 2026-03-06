import SwiftUI

extension Color {

    /// Initialize a `Color` from a hex string (e.g. "#E94560" or "E94560").
    ///
    /// Supports 3-digit (#RGB), 6-digit (#RRGGBB), and 8-digit (#AARRGGBB) formats.
    init(hex: String) {
        let sanitized = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)

        let r, g, b, a: Double

        switch sanitized.count {
        case 3: // RGB (12-bit)
            r = Double((rgb >> 8) & 0xF) / 15.0
            g = Double((rgb >> 4) & 0xF) / 15.0
            b = Double(rgb & 0xF) / 15.0
            a = 1.0

        case 6: // RRGGBB (24-bit)
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8)  & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0
            a = 1.0

        case 8: // AARRGGBB (32-bit)
            a = Double((rgb >> 24) & 0xFF) / 255.0
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8)  & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0

        default:
            r = 0; g = 0; b = 0; a = 1
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
