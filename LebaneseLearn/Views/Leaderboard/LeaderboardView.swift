import SwiftUI

// MARK: - Leaderboard View

struct LeaderboardView: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(AuthService.self) private var authService

    @State private var entries: [LeaderboardEntry] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let leaderboardService = LeaderboardService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                if isLoading {
                    loadingSkeleton
                } else if let errorMessage {
                    errorView(errorMessage)
                } else if entries.isEmpty {
                    emptyStateView
                } else {
                    leaderboardContent
                }
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingMD)
        }
        .background(Theme.bgMainAdaptive(for: colorScheme))
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(Theme.warning)
                        .font(.title3)
                    Text("Leaderboard")
                        .font(.headingMedium)
                        .foregroundStyle(Theme.textPrimary(for: colorScheme))
                }
            }
        }
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
                .fadeUpAnimation(delay: 0.0)
            }

            // Remaining users (rank 4+)
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

    private func leaderboardRow(_ entry: LeaderboardEntry) -> some View {
        HStack(spacing: Theme.spacingMD) {
            // Rank number
            Text("#\(entry.rank)")
                .font(.nunito(16, weight: .bold))
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
                .frame(width: 40, alignment: .leading)

            // Avatar circle with initial
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.info.opacity(0.6), Theme.info],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)

                Text(String(entry.name.prefix(1)).uppercased())
                    .font(.nunito(18, weight: .bold))
                    .foregroundStyle(.white)
            }

            // Name + level
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(entry.name)
                        .font(.nunito(15, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary(for: colorScheme))
                        .lineLimit(1)

                    if entry.isCurrentUser {
                        Text("(you)")
                            .font(.bodySmall)
                            .foregroundStyle(Theme.brand)
                    }
                }

                Text("Lv. \(entry.level) \(entry.levelTitle)")
                    .font(.bodySmall)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
                    .lineLimit(1)
            }

            Spacer()

            // XP badge
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.xpPurple)

                Text(formatXP(entry.totalXP))
                    .font(.nunito(14, weight: .bold))
                    .foregroundStyle(Theme.xpPurple)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Theme.xpDim)
            .clipShape(Capsule())
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, Theme.spacingSM)
        .background(Theme.bgCardAdaptive(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .strokeBorder(
                    entry.isCurrentUser ? Theme.brand.opacity(0.5) : Theme.border(for: colorScheme),
                    lineWidth: entry.isCurrentUser ? 2 : 1
                )
        )
        .shadow(
            color: Theme.cardShadow(for: colorScheme),
            radius: entry.isCurrentUser ? 8 : 4,
            x: 0,
            y: 2
        )
    }

    // MARK: - Loading Skeleton

    private var loadingSkeleton: some View {
        VStack(spacing: Theme.spacingLG) {
            // Podium skeleton
            HStack(alignment: .bottom, spacing: Theme.spacingMD) {
                ForEach(0..<3, id: \.self) { i in
                    VStack(spacing: Theme.spacingSM) {
                        Circle()
                            .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                            .frame(width: i == 1 ? 80 : 64, height: i == 1 ? 80 : 64)
                            .shimmer()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                            .frame(height: 14)
                            .shimmer()

                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                            .frame(height: CGFloat([100, 130, 80][i]))
                            .shimmer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Row skeletons
            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
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
                .foregroundStyle(Theme.textSecondary(for: colorScheme).opacity(0.4))

            Text("No Leaderboard Data")
                .font(.headingMedium)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            Text("Complete lessons and earn XP to appear on the leaderboard!")
                .font(.bodyLarge)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingXL)

            Spacer()
        }
        .padding(Theme.spacingMD)
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.warning)

            Text("Something went wrong")
                .font(.headingSmall)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            Text(message)
                .font(.bodyMedium)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)

            Button {
                Task { await loadLeaderboard() }
            } label: {
                Text("Retry")
                    .primaryButton()
            }
        }
        .padding(Theme.spacingXL)
    }

    // MARK: - Data Loading

    private func loadLeaderboard() async {
        isLoading = true
        errorMessage = nil

        do {
            entries = try await leaderboardService.fetchLeaderboard()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
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
    NavigationStack {
        LeaderboardView()
    }
    .environment(AuthService())
}
