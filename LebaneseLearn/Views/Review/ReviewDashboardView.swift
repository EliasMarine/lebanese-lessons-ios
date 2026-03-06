import SwiftUI

// MARK: - Review Dashboard View

struct ReviewDashboardView: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(AuthService.self) private var authService

    @State private var stats: ReviewStats?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var seedingPhaseId: Int?

    private let reviewService = ReviewService.shared

    // Phase definitions for "Add Flashcards by Phase" grid
    private let phases: [(id: Int, name: String, icon: String)] = [
        (1, "Phase 1", "1.circle.fill"),
        (2, "Phase 2", "2.circle.fill"),
        (3, "Phase 3", "3.circle.fill"),
        (4, "Phase 4", "4.circle.fill"),
        (5, "Phase 5", "5.circle.fill"),
        (6, "Phase 6", "6.circle.fill")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                if isLoading {
                    loadingSkeleton
                } else if let stats {
                    dashboardContent(stats)
                } else if let errorMessage {
                    errorView(errorMessage)
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
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(Theme.xpPurple)
                        .font(.title3)
                    Text("Spaced Repetition")
                        .font(.headingMedium)
                        .foregroundStyle(Theme.textPrimary(for: colorScheme))
                }
            }
        }
        .task {
            await loadStats()
        }
    }

    // MARK: - Dashboard Content

    @ViewBuilder
    private func dashboardContent(_ stats: ReviewStats) -> some View {

        // Cards Due hero card
        cardsDueHero(stats)
            .fadeUpAnimation(delay: 0.0)

        // Stats row (4 columns)
        statsRow(stats)
            .fadeUpAnimation(delay: 0.1)

        // Streak card
        streakCard(stats)
            .fadeUpAnimation(delay: 0.2)

        // Start Review button or All Caught Up
        reviewButton(stats)
            .fadeUpAnimation(delay: 0.3)

        // Quick stats row
        quickStatsRow(stats)
            .fadeUpAnimation(delay: 0.4)

        // Add Flashcards by Phase
        addFlashcardsSection(stats)
            .fadeUpAnimation(delay: 0.5)
    }

    // MARK: - Cards Due Hero

    private func cardsDueHero(_ stats: ReviewStats) -> some View {
        VStack(spacing: Theme.spacingSM) {
            Text("Cards Due")
                .font(.bodyMedium)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))

            Text("\(stats.dueNow)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(stats.dueNow > 0 ? Theme.brand : Theme.success)
                .shadow(
                    color: stats.dueNow > 0
                        ? Theme.brand.opacity(pulseOpacity)
                        : .clear,
                    radius: 20
                )

            Text(stats.dueNow > 0 ? "Ready for review" : "All caught up!")
                .font(.bodyMedium)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXL)
        .cardStyle()
    }

    @State private var pulseOpacity: Double = 0.3

    // MARK: - Stats Row

    private func statsRow(_ stats: ReviewStats) -> some View {
        HStack(spacing: Theme.spacingSM) {
            statColumn(
                icon: "rectangle.stack.fill",
                label: "Total",
                value: "\(stats.totalCards)",
                color: Theme.info
            )
            statColumn(
                icon: "checkmark.seal.fill",
                label: "Mastered",
                value: "\(stats.mastered)",
                color: Theme.success
            )
            statColumn(
                icon: "book.fill",
                label: "Learning",
                value: "\(stats.learning)",
                color: Theme.warning
            )
            statColumn(
                icon: "sparkles",
                label: "New",
                value: "\(stats.newCards)",
                color: Theme.xpPurple
            )
        }
    }

    private func statColumn(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.nunito(20, weight: .bold))
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingMD)
        .cardStyle()
    }

    // MARK: - Streak Card

    private func streakCard(_ stats: ReviewStats) -> some View {
        HStack(spacing: Theme.spacingMD) {
            // Flame icon
            ZStack {
                Circle()
                    .fill(Theme.warningDim)
                    .frame(width: 56, height: 56)

                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundStyle(
                        stats.streak > 0
                            ? LinearGradient(
                                colors: [Theme.warning, Theme.brand],
                                startPoint: .bottom,
                                endPoint: .top
                              )
                            : LinearGradient(
                                colors: [Theme.textSecondary(for: colorScheme)],
                                startPoint: .bottom,
                                endPoint: .top
                              )
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("\(stats.streak)")
                        .font(.headingLarge)
                        .foregroundStyle(Theme.textPrimary(for: colorScheme))

                    Text("Day Streak")
                        .font(.bodyLarge)
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                }

                Text(streakMessage(for: stats.streak))
                    .font(.bodySmall)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
            }

            Spacer()

            // XP multiplier badges
            if stats.streak >= 3 {
                VStack(spacing: 4) {
                    Text("\(xpMultiplier(for: stats.streak))x")
                        .font(.nunito(14, weight: .bold))
                        .foregroundStyle(Theme.xpPurple)

                    Text("XP")
                        .font(.caption)
                        .foregroundStyle(Theme.xpPurple)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Theme.xpDim)
                .clipShape(RoundedRectangle(cornerRadius: Theme.badgeRadius, style: .continuous))
            }
        }
        .padding(Theme.spacingMD)
        .cardStyle()
    }

    // MARK: - Review Button

    @ViewBuilder
    private func reviewButton(_ stats: ReviewStats) -> some View {
        if stats.dueNow > 0 {
            NavigationLink {
                ReviewSessionView()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text("Start Review (\(stats.dueNow) cards)")
                }
                .primaryButton()
            }
        } else {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Theme.success)
                Text("All caught up! Come back later.")
                    .font(.bodyLarge)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.successDim)
            .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius, style: .continuous))
        }
    }

    // MARK: - Quick Stats Row

    private func quickStatsRow(_ stats: ReviewStats) -> some View {
        HStack(spacing: Theme.spacingSM) {
            quickStatItem(
                label: "Avg Ease",
                value: String(format: "%.1f", stats.avgEaseFactor),
                icon: "gauge.medium"
            )
            quickStatItem(
                label: "Retention",
                value: "\(stats.retentionRate)%",
                icon: "chart.bar.fill"
            )
            quickStatItem(
                label: "Last Review",
                value: formatLastReview(stats.lastReviewAt),
                icon: "clock.fill"
            )
        }
    }

    private func quickStatItem(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))

            Text(value)
                .font(.nunito(15, weight: .semibold))
                .foregroundStyle(Theme.textPrimary(for: colorScheme))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingSM)
        .padding(.horizontal, Theme.spacingXS)
        .cardStyle()
    }

    // MARK: - Add Flashcards Section

    private func addFlashcardsSection(_ stats: ReviewStats) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack(spacing: 8) {
                Image(systemName: "plus.rectangle.on.rectangle")
                    .foregroundStyle(Theme.info)
                Text("Add Flashcards by Phase")
                    .font(.headingSmall)
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))
            }
            .padding(.horizontal, 4)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Theme.spacingSM),
                    GridItem(.flexible(), spacing: Theme.spacingSM),
                    GridItem(.flexible(), spacing: Theme.spacingSM)
                ],
                spacing: Theme.spacingSM
            ) {
                ForEach(phases, id: \.id) { phase in
                    phaseButton(phase)
                }
            }
        }
    }

    private func phaseButton(_ phase: (id: Int, name: String, icon: String)) -> some View {
        Button {
            Task {
                await seedPhase(phase.id)
            }
        } label: {
            VStack(spacing: 6) {
                if seedingPhaseId == phase.id {
                    ProgressView()
                        .tint(Theme.info)
                        .frame(height: 24)
                } else {
                    Image(systemName: phase.icon)
                        .font(.title3)
                        .foregroundStyle(Theme.info)
                }

                Text(phase.name)
                    .font(.bodySmall)
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacingSM)
            .background(Theme.infoDim)
            .clipShape(RoundedRectangle(cornerRadius: Theme.badgeRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.badgeRadius, style: .continuous)
                    .strokeBorder(Theme.border(for: colorScheme), lineWidth: 1)
            )
        }
        .disabled(seedingPhaseId != nil)
    }

    // MARK: - Loading Skeleton

    private var loadingSkeleton: some View {
        VStack(spacing: Theme.spacingLG) {
            // Hero skeleton
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                .frame(height: 160)
                .shimmer()

            // Stats row skeleton
            HStack(spacing: Theme.spacingSM) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                        .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                        .frame(height: 100)
                        .shimmer()
                }
            }

            // Streak skeleton
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                .frame(height: 80)
                .shimmer()

            // Button skeleton
            RoundedRectangle(cornerRadius: Theme.buttonRadius, style: .continuous)
                .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                .frame(height: 50)
                .shimmer()
        }
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
                Task { await loadStats() }
            } label: {
                Text("Retry")
                    .primaryButton()
            }
        }
        .padding(Theme.spacingXL)
    }

    // MARK: - Data Loading

    private func loadStats() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedStats = try await reviewService.fetchStats()
            stats = fetchedStats

            // Auto-seed if no cards exist
            if fetchedStats.totalCards == 0 {
                try await reviewService.seedPhase(phaseId: 1)
                stats = try await reviewService.fetchStats()
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false

        // Start pulsing animation for cards due
        if let stats, stats.dueNow > 0 {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                pulseOpacity = 0.8
            }
        }
    }

    private func seedPhase(_ phaseId: Int) async {
        seedingPhaseId = phaseId
        do {
            try await reviewService.seedPhase(phaseId: phaseId)
            stats = try await reviewService.fetchStats()
        } catch {
            errorMessage = error.localizedDescription
        }
        seedingPhaseId = nil
    }

    // MARK: - Helpers

    private func streakMessage(for streak: Int) -> String {
        switch streak {
        case 0:      return "Start reviewing to build your streak!"
        case 1:      return "Great start! Keep it going!"
        case 2...6:  return "You're on fire! Don't break the chain!"
        case 7...13: return "A whole week! Incredible dedication!"
        case 14...29: return "Two weeks strong! You're unstoppable!"
        default:     return "Legendary streak! You're a master!"
        }
    }

    private func xpMultiplier(for streak: Int) -> String {
        switch streak {
        case 3...6:  return "1.5"
        case 7...13: return "2.0"
        case 14...29: return "2.5"
        case 30...:  return "3.0"
        default:     return "1.0"
        }
    }

    private func formatLastReview(_ dateString: String?) -> String {
        guard let dateString, !dateString.isEmpty else { return "Never" }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: dateString)
                ?? ISO8601DateFormatter().date(from: dateString) else {
            return "N/A"
        }

        let relative = RelativeDateTimeFormatter()
        relative.unitsStyle = .abbreviated
        return relative.localizedString(for: date, relativeTo: .now)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReviewDashboardView()
    }
    .environment(AuthService())
}
