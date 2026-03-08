import SwiftUI

/// A 2x2 grid of colored squares representing the Mosaic logo.
///
/// Uses the brand palette: red (top-left), purple (top-right),
/// yellow (bottom-left), blue (bottom-right) with small gaps.
struct MosaicLogo: View {
    let size: CGFloat
    var gap: CGFloat?

    private var resolvedGap: CGFloat {
        gap ?? (size * 0.06)
    }

    private var tileSize: CGFloat {
        (size - resolvedGap) / 2
    }

    var body: some View {
        let colors: [[Color]] = [
            [Theme.duoGreen,  Theme.duoPurple],
            [Theme.duoYellow, Theme.duoBlue]
        ]

        VStack(spacing: resolvedGap) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: resolvedGap) {
                    ForEach(0..<2, id: \.self) { col in
                        RoundedRectangle(cornerRadius: size * 0.08)
                            .fill(colors[row][col])
                            .frame(width: tileSize, height: tileSize)
                    }
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        MosaicLogo(size: 80)
        MosaicLogo(size: 48)
        MosaicLogo(size: 32)
    }
    .padding()
}
