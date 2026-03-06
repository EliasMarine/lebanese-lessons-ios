import SwiftUI

// MARK: - Podium View

struct PodiumView: View {

    let first: LeaderboardEntry
    let second: LeaderboardEntry
    let third: LeaderboardEntry

    @Environment(\.colorScheme) private var colorScheme

    @State private var animateIn = false

    var body: some View {
        HStack(alignment: .bottom, spacing: Theme.spacingSM) {
            // 2nd Place (left)
            podiumColumn(
                entry: second,
                place: 2,
                avatarSize: 64,
                podiumHeight: 100,
                medalIcon: "medal.fill",
                medalColor: Color(hex: "#C0C0C0"), // Silver
                avatarGradient: [Color(hex: "#636E72"), Color(hex: "#B2BEC3")],
                podiumGradient: [Color(hex: "#636E72").opacity(0.7), Color(hex: "#636E72").opacity(0.3)]
            )

            // 1st Place (center, tallest)
            podiumColumn(
                entry: first,
                place: 1,
                avatarSize: 80,
                podiumHeight: 130,
                medalIcon: "crown.fill",
                medalColor: Theme.warning,
                avatarGradient: [Theme.brand, Theme.brand.opacity(0.7)],
                podiumGradient: [Theme.brand.opacity(0.8), Theme.brand.opacity(0.3)]
            )

            // 3rd Place (right)
            podiumColumn(
                entry: third,
                place: 3,
                avatarSize: 64,
                podiumHeight: 75,
                medalIcon: "medal.fill",
                medalColor: Color(hex: "#CD7F32"), // Bronze
                avatarGradient: [Color(hex: "#FDCB6E"), Color(hex: "#E17055")],
                podiumGradient: [Color(hex: "#CD7F32").opacity(0.7), Color(hex: "#CD7F32").opacity(0.3)]
            )
        }
        .padding(.top, Theme.spacingLG)
        .padding(.horizontal, Theme.spacingXS)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateIn = true
            }
        }
    }

    // MARK: - Podium Column

    private func podiumColumn(
        entry: LeaderboardEntry,
        place: Int,
        avatarSize: CGFloat,
        podiumHeight: CGFloat,
        medalIcon: String,
        medalColor: Color,
        avatarGradient: [Color],
        podiumGradient: [Color]
    ) -> some View {
        VStack(spacing: 0) {
            // Medal / Crown icon
            Image(systemName: medalIcon)
                .font(place == 1 ? .title2 : .body)
                .foregroundStyle(medalColor)
                .shadow(color: medalColor.opacity(0.5), radius: 4, x: 0, y: 2)
                .padding(.bottom, 4)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : -10)

            // Avatar with initial
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: avatarGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: avatarSize, height: avatarSize)
                    .shadow(color: avatarGradient[0].opacity(0.4), radius: 8, x: 0, y: 4)

                Text(String(entry.name.prefix(1)).uppercased())
                    .font(.nunito(avatarSize * 0.4, weight: .bold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(animateIn ? 1 : 0.5)
            .opacity(animateIn ? 1 : 0)

            // Name
            VStack(spacing: 2) {
                Text(entry.name)
                    .font(.nunito(place == 1 ? 15 : 13, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if entry.isCurrentUser {
                    Text("(you)")
                        .font(.caption)
                        .foregroundStyle(Theme.brand)
                }
            }
            .padding(.top, 6)
            .opacity(animateIn ? 1 : 0)

            // Level info
            Text("Lv. \(entry.level)")
                .font(.bodySmall)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
                .padding(.top, 2)
                .opacity(animateIn ? 1 : 0)

            // XP badge
            HStack(spacing: 3) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.xpPurple)

                Text(formatXP(entry.totalXP))
                    .font(.nunito(12, weight: .bold))
                    .foregroundStyle(Theme.xpPurple)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Theme.xpDim)
            .clipShape(Capsule())
            .padding(.top, 6)
            .opacity(animateIn ? 1 : 0)

            // Podium bar
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: podiumGradient,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: animateIn ? podiumHeight : 0)

                // Rank label on podium
                Text("\(place)")
                    .font(.nunito(place == 1 ? 28 : 22, weight: .bold))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 10)
                    .opacity(animateIn ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func formatXP(_ xp: Int) -> String {
        if xp >= 1000 {
            let k = Double(xp) / 1000.0
            return String(format: "%.1fk", k)
        }
        return "\(xp)"
    }
}

// MARK: - Preview

#Preview {
    PodiumView(
        first: LeaderboardEntry(
            id: "1", rank: 1, name: "Elias",
            totalXP: 2450, level: 5, levelTitle: "Scholar",
            levelProgress: LevelProgress(current: 450, needed: 500, progress: 0.9),
            isCurrentUser: true
        ),
        second: LeaderboardEntry(
            id: "2", rank: 2, name: "Sarah",
            totalXP: 1800, level: 4, levelTitle: "Learner",
            levelProgress: LevelProgress(current: 300, needed: 400, progress: 0.75),
            isCurrentUser: false
        ),
        third: LeaderboardEntry(
            id: "3", rank: 3, name: "Mike",
            totalXP: 1200, level: 3, levelTitle: "Beginner",
            levelProgress: LevelProgress(current: 200, needed: 300, progress: 0.67),
            isCurrentUser: false
        )
    )
    .padding()
    .background(Color(hex: "#0F0F1A"))
}
