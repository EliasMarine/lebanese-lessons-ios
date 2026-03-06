import SwiftUI

// MARK: - Stat Card

/// A reusable statistics card displaying an SF Symbol icon, value, and label.
///
/// Usage:
/// ```swift
/// StatCard(icon: "flame.fill", value: "42", label: "STREAK", color: Theme.warning)
/// ```
struct StatCard: View {

    let icon: String
    let value: String
    let label: String
    let color: Color

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: Theme.spacingSM) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
            }

            // Value
            Text(value)
                .font(.nunito(22, weight: .bold))
                .foregroundStyle(Theme.textPrimary(for: colorScheme))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Label
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
                .textCase(.uppercase)
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingMD)
        .padding(.horizontal, Theme.spacingSM)
        .cardStyle()
    }
}

// MARK: - Preview

#Preview {
    LazyVGrid(
        columns: [GridItem(.flexible()), GridItem(.flexible())],
        spacing: 12
    ) {
        StatCard(icon: "star.fill", value: "1,250", label: "Total XP", color: Theme.xpPurple)
        StatCard(icon: "trophy.fill", value: "5", label: "Level", color: Theme.warning)
        StatCard(icon: "flame.fill", value: "12", label: "Streak", color: Theme.brand)
        StatCard(icon: "rectangle.stack.fill", value: "48", label: "Mastered", color: Theme.success)
    }
    .padding()
}
