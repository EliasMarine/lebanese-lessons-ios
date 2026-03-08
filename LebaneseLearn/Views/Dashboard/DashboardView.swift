import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    private let quickActions: [(title: String, icon: String, tint: Color, destination: QuickActionDestination)] = [
        ("Continue Learning", "book.fill", Theme.electricBlue, .lessons),
        ("Review Cards", "rectangle.stack.fill", Theme.vividGreen, .review),
        ("AI Chat", "bubble.left.and.bubble.right.fill", Theme.brightPurple, .aiChat),
    ]

    enum QuickActionDestination: Hashable {
        case lessons, review, aiChat
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                greetingSection
                    .fadeUpAnimation()

                levelSection
                    .fadeUpAnimation(delay: 0.1)

                quickActionsSection
                    .fadeUpAnimation(delay: 0.2)
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.top, Theme.spacingMD)
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Greeting Section

    private var greetingSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(greetingText)
                    .font(.headingLarge)

                Text(profile?.name ?? "Learner")
                    .font(.headingMedium)
                    .foregroundStyle(Theme.brand)
            }

            Spacer()

            HStack(spacing: Theme.spacingSM) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                    Text("\(profile?.streak ?? 0)")
                }
                .streakBadge()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                    Text("\(profile?.totalXP ?? 0) XP")
                }
                .xpBadge()
            }
        }
        .glassCard()
    }

    // MARK: - Level Section

    private var levelSection: some View {
        VStack(spacing: Theme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text("Level \(profile?.level ?? 1)")
                        .font(.headingSmall)
                    Text(profile?.levelTitle ?? "Beginner")
                        .font(.bodyMedium)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ProgressRing(
                    progress: levelProgress,
                    size: 56,
                    lineWidth: 6,
                    tint: Theme.brightPurple
                )
                .overlay {
                    Text("\(Int(levelProgress * 100))%")
                        .font(.nunito(11, weight: .bold))
                        .foregroundStyle(Theme.brightPurple)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.brightPurple.opacity(0.2))
                        .frame(height: 8)

                    Capsule()
                        .fill(Theme.brightPurple)
                        .frame(width: geometry.size.width * levelProgress, height: 8)
                        .animation(.easeInOut(duration: 0.6), value: levelProgress)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(profile?.currentXPInLevel ?? 0) XP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(profile?.xpNeededForLevel ?? 200) XP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .glassCard(tint: Theme.brightPurple)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("Quick Actions")
                .font(.headingSmall)
                .padding(.leading, Theme.spacingXS)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Theme.spacingMD),
                GridItem(.flexible(), spacing: Theme.spacingMD),
            ], spacing: Theme.spacingMD) {
                ForEach(quickActions, id: \.title) { action in
                    NavigationLink(value: action.destination) {
                        VStack(spacing: Theme.spacingSM) {
                            Image(systemName: action.icon)
                                .font(.title)
                                .foregroundStyle(action.tint)
                            Text(action.title)
                                .font(.nunito(14, weight: .semibold))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 100)
                        .glassCard(tint: action.tint)
                    }
                }
            }
        }
        .navigationDestination(for: QuickActionDestination.self) { destination in
            switch destination {
            case .lessons:
                LessonsListView()
            case .review:
                ReviewDashboardView()
            case .aiChat:
                AIChatView()
            }
        }
    }

    // MARK: - Helpers

    private var levelProgress: Double {
        guard let profile, profile.xpNeededForLevel > 0 else { return 0 }
        return Double(profile.currentXPInLevel) / Double(profile.xpNeededForLevel)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning,"
        case 12..<17: return "Good afternoon,"
        case 17..<21: return "Good evening,"
        default: return "Welcome back,"
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(for: UserProfile.self, inMemory: true)
}
