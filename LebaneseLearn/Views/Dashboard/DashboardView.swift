import SwiftUI

// MARK: - Dashboard View

struct DashboardView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.colorScheme) private var colorScheme

    // MARK: State

    @State private var isLoading = true
    @State private var cardsDue: Int = 0
    @State private var totalCards: Int = 0
    @State private var masteredCards: Int = 0
    @State private var learningCards: Int = 0
    @State private var newCards: Int = 0
    @State private var streak: Int = 0
    @State private var dailyChallenges: [DailyChallenge] = []

    // Animation
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bgMainAdaptive(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Theme.spacingLG) {
                        // Welcome Header
                        welcomeHeader
                            .fadeUpAnimation(delay: 0.0)

                        // XP Progress
                        xpProgressCard
                            .fadeUpAnimation(delay: 0.08)

                        // Cards Due Hero
                        cardsDueHero
                            .fadeUpAnimation(delay: 0.16)

                        // Quick Stats Grid
                        quickStatsGrid
                            .fadeUpAnimation(delay: 0.24)

                        // Streak Card
                        streakCard
                            .fadeUpAnimation(delay: 0.32)

                        // Daily Challenges
                        dailyChallengesSection
                            .fadeUpAnimation(delay: 0.40)

                        // Start Review Button
                        if cardsDue > 0 {
                            startReviewButton
                                .fadeUpAnimation(delay: 0.48)
                        }

                        Spacer()
                            .frame(height: Theme.spacingLG)
                    }
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.top, Theme.spacingSM)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadDashboardData()
            }
        }
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text("Welcome back,")
                    .font(.bodyLarge)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))

                Text(authService.currentUser?.name ?? "Learner")
                    .font(.headingLarge)
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))
            }

            Spacer()

            // Level Badge
            if let user = authService.currentUser {
                levelBadge(level: user.level, title: user.levelTitle)
            }
        }
        .padding(.horizontal, Theme.spacingXS)
    }

    // MARK: - Level Badge

    private func levelBadge(level: Int, title: String) -> some View {
        VStack(spacing: 2) {
            Text("Lv. \(level)")
                .font(.nunito(18, weight: .bold))
                .foregroundStyle(Theme.xpPurple)

            Text(title)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Theme.xpDim)
        .clipShape(RoundedRectangle(cornerRadius: Theme.badgeRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.badgeRadius, style: .continuous)
                .strokeBorder(Theme.xpPurple.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - XP Progress Card

    private var xpProgressCard: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(Theme.xpPurple)
                    .font(.system(size: 14))

                Text("XP Progress")
                    .font(.headingSmall)
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))

                Spacer()

                if let user = authService.currentUser {
                    Text("\(user.totalXP) XP")
                        .font(.nunito(14, weight: .bold))
                        .foregroundStyle(Theme.xpPurple)
                }
            }

            if let user = authService.currentUser {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Theme.xpDim)
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.xpPurple, Theme.xpPurple.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: max(0, geometry.size.width * user.levelProgress.progress),
                                height: 12
                            )
                    }
                }
                .frame(height: 12)

                HStack {
                    Text("\(user.levelProgress.current) / \(user.levelProgress.needed) XP")
                        .font(.bodySmall)
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))

                    Spacer()

                    Text("Level \(user.level + 1)")
                        .font(.bodySmall)
                        .foregroundStyle(Theme.xpPurple)
                }
            }
        }
        .padding(Theme.spacingMD)
        .cardStyle()
    }

    // MARK: - Cards Due Hero

    private var cardsDueHero: some View {
        VStack(spacing: Theme.spacingSM) {
            ZStack {
                // Pulsing glow ring when cards are due
                if cardsDue > 0 {
                    Circle()
                        .fill(Theme.info.opacity(0.12))
                        .frame(width: 100, height: 100)
                        .modifier(PulseModifier())
                }

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.info.opacity(0.15), Theme.info.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.info)
            }

            Text("\(cardsDue)")
                .font(.nunito(48, weight: .bold))
                .foregroundStyle(Theme.textPrimary(for: colorScheme))
                .contentTransition(.numericText())

            Text("Cards Due for Review")
                .font(.bodyLarge)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingLG)
        .padding(.horizontal, Theme.spacingMD)
        .cardStyle()
    }

    // MARK: - Quick Stats Grid

    private var quickStatsGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: Theme.spacingSM), count: 4),
            spacing: Theme.spacingSM
        ) {
            StatCell(
                title: "Total",
                value: "\(totalCards)",
                icon: "rectangle.stack.fill",
                color: Theme.info
            )

            StatCell(
                title: "Mastered",
                value: "\(masteredCards)",
                icon: "checkmark.seal.fill",
                color: Theme.success
            )

            StatCell(
                title: "Learning",
                value: "\(learningCards)",
                icon: "arrow.triangle.2.circlepath",
                color: Theme.warning
            )

            StatCell(
                title: "New",
                value: "\(newCards)",
                icon: "sparkles",
                color: Theme.xpPurple
            )
        }
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        HStack(spacing: Theme.spacingMD) {
            // Flame icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.warning.opacity(0.2), Theme.brand.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: "flame.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.warning, Theme.brand],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(streak)")
                        .font(.nunito(28, weight: .bold))
                        .foregroundStyle(Theme.textPrimary(for: colorScheme))

                    Text("day streak")
                        .font(.bodyLarge)
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                }

                Text(streakMotivation)
                    .font(.bodySmall)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
            }

            Spacer()
        }
        .padding(Theme.spacingMD)
        .cardStyle()
    }

    private var streakMotivation: String {
        switch streak {
        case 0:     return "Start a streak today!"
        case 1...2: return "Great start! Keep going!"
        case 3...6: return "You're building momentum!"
        case 7...13: return "One week strong!"
        case 14...29: return "Impressive dedication!"
        default:     return "Unstoppable! Keep it up!"
        }
    }

    // MARK: - Daily Challenges Section

    private var dailyChallengesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Image(systemName: "target")
                    .foregroundStyle(Theme.brand)
                    .font(.system(size: 14))

                Text("Daily Challenges")
                    .font(.headingSmall)
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))
            }
            .padding(.horizontal, Theme.spacingXS)

            ForEach(dailyChallenges) { challenge in
                challengeRow(challenge)
            }

            if dailyChallenges.isEmpty && !isLoading {
                Text("No challenges available today.")
                    .font(.bodyMedium)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingLG)
            }
        }
    }

    private func challengeRow(_ challenge: DailyChallenge) -> some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: challenge.icon)
                .font(.system(size: 16))
                .foregroundStyle(challenge.isCompleted ? Theme.success : Theme.textSecondary(for: colorScheme))
                .frame(width: 28, height: 28)
                .background(
                    challenge.isCompleted
                        ? Theme.successDim
                        : Theme.bgSurfaceAdaptive(for: colorScheme)
                )
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.title)
                    .font(.nunito(14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))
                    .strikethrough(challenge.isCompleted, color: Theme.textSecondary(for: colorScheme))

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(challenge.isCompleted ? Theme.success : Theme.brand)
                            .frame(
                                width: max(0, geometry.size.width * challenge.progress),
                                height: 6
                            )
                    }
                }
                .frame(height: 6)
            }

            Spacer()

            Text("+\(challenge.xpReward) XP")
                .font(.caption)
                .foregroundStyle(challenge.isCompleted ? Theme.success : Theme.xpPurple)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    challenge.isCompleted ? Theme.successDim : Theme.xpDim
                )
                .clipShape(Capsule())
        }
        .padding(12)
        .cardStyle()
    }

    // MARK: - Start Review Button

    private var startReviewButton: some View {
        Button {
            // TODO: Navigate to review session
        } label: {
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 18, weight: .semibold))
                Text("Start Review (\(cardsDue) cards)")
                    .font(.nunito(16, weight: .bold))
            }
            .primaryButton()
        }
    }

    // MARK: - Data Loading

    private func loadDashboardData() async {
        isLoading = true

        // Simulate loading dashboard data from the API
        // In production, this would call ReviewService and LeaderboardService
        try? await Task.sleep(for: .milliseconds(300))

        // Populate with user data if available
        if let user = authService.currentUser {
            streak = user.streak
        }

        // Sample challenge data -- will be replaced with real API calls
        dailyChallenges = [
            DailyChallenge(
                id: "1",
                type: "review",
                title: "Review 10 cards",
                description: "Review 10 flashcards today",
                target: 10,
                current: 3,
                xpReward: 50,
                completed: false
            ),
            DailyChallenge(
                id: "2",
                type: "learn",
                title: "Learn 5 new words",
                description: "Learn 5 new vocabulary words",
                target: 5,
                current: 3,
                xpReward: 30,
                completed: false
            ),
            DailyChallenge(
                id: "3",
                type: "lesson",
                title: "Complete a lesson",
                description: "Complete any lesson",
                target: 1,
                current: 1,
                xpReward: 100,
                completed: true
            ),
        ]

        isLoading = false
    }
}

// MARK: - Stat Cell

/// A single statistic tile in the 4-column grid.
private struct StatCell: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(value)
                .font(.nunito(18, weight: .bold))
                .foregroundStyle(Theme.textPrimary(for: colorScheme))
                .contentTransition(.numericText())

            Text(title)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .cardStyle()
    }
}

// MARK: - Pulse Modifier

/// Subtle pulsing glow animation for the cards-due indicator.
private struct PulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.15 : 0.95)
            .opacity(isPulsing ? 0.0 : 0.6)
            .animation(
                .easeInOut(duration: 1.8)
                .repeatForever(autoreverses: false),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(AuthService())
}
