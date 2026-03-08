import SwiftUI

struct PodiumView: View {
    let first: CloudKitService.LeaderboardEntry
    let second: CloudKitService.LeaderboardEntry
    let third: CloudKitService.LeaderboardEntry

    @State private var animateIn = false

    var body: some View {
        HStack(alignment: .bottom, spacing: Theme.spacingSM) {
            // 2nd Place (left, shorter)
            podiumColumn(
                entry: second,
                place: 2,
                medal: "\u{1F948}", // Silver medal
                avatarSize: 64,
                podiumHeight: 100,
                gradient: [.gray.opacity(0.6), .gray.opacity(0.3)]
            )

            // 1st Place (center, tallest)
            podiumColumn(
                entry: first,
                place: 1,
                medal: "\u{1F947}", // Gold medal
                avatarSize: 80,
                podiumHeight: 130,
                gradient: [Theme.brand.opacity(0.8), Theme.brand.opacity(0.3)]
            )

            // 3rd Place (right, shortest)
            podiumColumn(
                entry: third,
                place: 3,
                medal: "\u{1F949}", // Bronze medal
                avatarSize: 64,
                podiumHeight: 75,
                gradient: [Theme.sunsetOrange.opacity(0.7), Theme.sunsetOrange.opacity(0.3)]
            )
        }
        .padding(.top, Theme.spacingLG)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateIn = true
            }
        }
    }

    // MARK: - Podium Column

    private func podiumColumn(
        entry: CloudKitService.LeaderboardEntry,
        place: Int,
        medal: String,
        avatarSize: CGFloat,
        podiumHeight: CGFloat,
        gradient: [Color]
    ) -> some View {
        VStack(spacing: 0) {
            // Medal
            Text(medal)
                .font(.system(size: place == 1 ? 32 : 24))
                .padding(.bottom, 4)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : -10)

            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: avatarSize, height: avatarSize)

                Text(String(entry.name.prefix(1)).uppercased())
                    .font(.nunito(avatarSize * 0.4, weight: .bold))
                    .foregroundStyle(.white)
            }
            .background(Color.gray.opacity(0.1))
            .clipShape(Circle())
            .scaleEffect(animateIn ? 1 : 0.5)
            .opacity(animateIn ? 1 : 0)

            // Name
            Text(entry.name)
                .font(.nunito(place == 1 ? 15 : 13, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.top, 6)
                .opacity(animateIn ? 1 : 0)

            // XP badge
            HStack(spacing: 3) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.brightPurple)
                Text(formatXP(entry.totalXP))
                    .font(.nunito(12, weight: .bold))
                    .foregroundStyle(Theme.brightPurple)
            }
            .xpBadge()
            .padding(.top, 4)
            .opacity(animateIn ? 1 : 0)

            // Podium bar
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 0, x: 0, y: 3)
                    .frame(height: animateIn ? podiumHeight : 0)

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
            return String(format: "%.1fk", Double(xp) / 1000.0)
        }
        return "\(xp)"
    }
}
