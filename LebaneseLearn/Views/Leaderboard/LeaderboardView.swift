import SwiftUI
import SwiftData

struct LeaderboardView: View {
    @Query private var profiles: [UserProfile]
    @State private var entries: [CloudKitService.LeaderboardEntry] = []
    @State private var isLoading = true

    private var profile: UserProfile? { profiles.first }
    private let service = CloudKitService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                if isLoading {
                    loadingSkeleton
                } else if entries.isEmpty {
                    emptyStateView
                } else {
                    leaderboardContent
                }
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingMD)
        }
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await loadLeaderboard()
        }
        .task {
            await loadLeaderboard()
        }
    }

    // MARK: - Leaderboard Content

    private var leaderboardContent: some View {
        VStack(spacing: Theme.spacingLG) {
            // Podium for top 3
            if entries.count >= 3 {
                PodiumView(
                    first: entries[0],
                    second: entries[1],
                    third: entries[2]
                )
                .fadeUpAnimation()
            }

            // Remaining entries (rank 4+)
            if entries.count > 3 {
                VStack(spacing: Theme.spacingSM) {
                    ForEach(Array(entries.dropFirst(3).enumerated()), id: \.element.id) { index, entry in
                        leaderboardRow(entry)
                            .fadeUpAnimation(delay: 0.1 + Double(index) * 0.05)
                    }
                }
            }
        }
    }

    // MARK: - Leaderboard Row

    private func leaderboardRow(_ entry: CloudKitService.LeaderboardEntry) -> some View {
        let isCurrentUser = entry.name == profile?.name

        return HStack(spacing: Theme.spacingMD) {
            Text("#\(entry.rank)")
                .font(.nunito(16, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)

            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.electricBlue.opacity(0.6), Theme.electricBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)

                Text(String(entry.name.prefix(1)).uppercased())
                    .font(.nunito(18, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(entry.name)
                        .font(.nunito(15, weight: .semibold))
                        .lineLimit(1)

                    if isCurrentUser {
                        Text("(you)")
                            .font(.bodySmall)
                            .foregroundStyle(Theme.brand)
                    }
                }

                Text("Lv. \(entry.level) \(entry.levelTitle)")
                    .font(.bodySmall)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.brightPurple)
                Text(formatXP(entry.totalXP))
                    .font(.nunito(14, weight: .bold))
                    .foregroundStyle(Theme.brightPurple)
            }
            .xpBadge()
        }
        .duoCard(tint: isCurrentUser ? Theme.brand : .clear)
    }

    // MARK: - Loading Skeleton

    private var loadingSkeleton: some View {
        VStack(spacing: Theme.spacingLG) {
            HStack(alignment: .bottom, spacing: Theme.spacingMD) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(spacing: Theme.spacingSM) {
                        Circle()
                            .fill(.secondary.opacity(0.1))
                            .frame(width: 64, height: 64)
                            .shimmer()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(.secondary.opacity(0.1))
                            .frame(height: 14)
                            .shimmer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Theme.cardRadius)
                    .fill(.secondary.opacity(0.1))
                    .frame(height: 60)
                    .shimmer()
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Theme.spacingMD) {
            Spacer()

            Image(systemName: "trophy")
                .font(.system(size: 64))
                .foregroundStyle(.secondary.opacity(0.4))

            Text("No Leaderboard Data")
                .font(.headingMedium)

            Text("Complete lessons and earn XP to appear on the leaderboard!")
                .font(.bodyLarge)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(Theme.spacingMD)
    }

    // MARK: - Data Loading

    private func loadLeaderboard() async {
        isLoading = true
        await service.fetchLeaderboard()
        entries = service.entries
        isLoading = false
    }

    // MARK: - Helpers

    private func formatXP(_ xp: Int) -> String {
        if xp >= 1000 {
            return String(format: "%.1fk", Double(xp) / 1000.0)
        }
        return "\(xp)"
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
    .modelContainer(for: UserProfile.self, inMemory: true)
}
