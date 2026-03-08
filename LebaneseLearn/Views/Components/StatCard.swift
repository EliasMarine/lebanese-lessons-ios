import SwiftUI

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var tint: Color = Theme.brand

    var body: some View {
        VStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)
            Text(value)
                .font(.headingSmall)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .duoCard(tint: tint)
    }
}

#Preview {
    LazyVGrid(
        columns: [GridItem(.flexible()), GridItem(.flexible())],
        spacing: 12
    ) {
        StatCard(icon: "star.fill", title: "Total XP", value: "1,250", tint: Theme.brightPurple)
        StatCard(icon: "trophy.fill", title: "Level", value: "5", tint: Theme.goldenYellow)
        StatCard(icon: "flame.fill", title: "Streak", value: "12", tint: Theme.sunsetOrange)
        StatCard(icon: "rectangle.stack.fill", title: "Mastered", value: "48", tint: Theme.vividGreen)
    }
    .padding()
}
