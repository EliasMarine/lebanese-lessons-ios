import SwiftUI

// MARK: - Profile View

struct ProfileView: View {

    @Environment(AuthService.self) private var authService
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true

    @State private var badges: [Badge] = []
    @State private var reviewStats: ReviewStats?
    @State private var isLoadingBadges = true
    @State private var showSignOutConfirm = false

    private let reviewService = ReviewService.shared

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                avatarSection
                    .fadeUpAnimation(delay: 0.05)

                xpProgressSection
                    .fadeUpAnimation(delay: 0.1)

                statsGrid
                    .fadeUpAnimation(delay: 0.15)

                settingsSection
                    .fadeUpAnimation(delay: 0.2)

                badgesSection
                    .fadeUpAnimation(delay: 0.25)

                signOutButton
                    .fadeUpAnimation(delay: 0.3)
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.top, Theme.spacingSM)
            .padding(.bottom, Theme.spacingXL)
        }
        .background(Theme.bgMainAdaptive(for: colorScheme))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await refreshData()
        }
        .task {
            await loadData()
        }
        .confirmationDialog(
            "Sign Out",
            isPresented: $showSignOutConfirm,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                authService.logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: Theme.spacingSM) {
            // Avatar circle with initial
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.brand, Theme.brand.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: Theme.brand.opacity(0.3), radius: 12, x: 0, y: 4)

                Text(userInitial)
                    .font(.nunito(40, weight: .bold))
                    .foregroundStyle(.white)
            }

            // Name
            Text(authService.currentUser?.name ?? "Learner")
                .font(.headingMedium)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            // Email
            Text(authService.currentUser?.email ?? "")
                .font(.bodyMedium)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))

            // Level badge
            if let user = authService.currentUser {
                HStack(spacing: 6) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 12))
                    Text("Level \(user.level) \u{2022} \(user.levelTitle)")
                        .font(.nunito(13, weight: .semibold))
                }
                .foregroundStyle(Theme.xpPurple)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Theme.xpDim)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingLG)
    }

    // MARK: - XP Progress Section

    private var xpProgressSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Text("XP Progress")
                    .font(.headingSmall)
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))

                Spacer()

                if let user = authService.currentUser {
                    Text("\(user.levelProgress.current) / \(user.levelProgress.needed) XP")
                        .font(.bodySmall)
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.xpPurple.opacity(0.15))
                        .frame(height: 12)

                    // Fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Theme.xpPurple, Theme.xpPurple.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * xpProgress,
                            height: 12
                        )
                        .animation(.easeOut(duration: 0.8), value: xpProgress)
                }
            }
            .frame(height: 12)

            // Level labels
            HStack {
                Text("Level \(authService.currentUser?.level ?? 1)")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
                Spacer()
                Text("Level \((authService.currentUser?.level ?? 1) + 1)")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
            }
        }
        .padding(Theme.spacingMD)
        .cardStyle()
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12
        ) {
            StatCard(
                icon: "star.fill",
                value: formattedXP,
                label: "Total XP",
                color: Theme.xpPurple
            )

            StatCard(
                icon: "trophy.fill",
                value: "\(authService.currentUser?.level ?? 1)",
                label: "Level",
                color: Theme.warning
            )

            StatCard(
                icon: "flame.fill",
                value: "\(authService.currentUser?.streak ?? 0)",
                label: "Day Streak",
                color: Theme.brand
            )

            StatCard(
                icon: "rectangle.stack.fill",
                value: "\(reviewStats?.mastered ?? 0)",
                label: "Mastered",
                color: Theme.success
            )
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Settings")
                .font(.headingSmall)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))
                .padding(.bottom, Theme.spacingSM)

            VStack(spacing: 0) {
                settingsRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    color: Theme.info
                ) {
                    Toggle("", isOn: $isDarkMode)
                        .tint(Theme.brand)
                        .labelsHidden()
                }

                Divider()
                    .padding(.leading, 52)

                settingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    color: Theme.warning
                ) {
                    Toggle("", isOn: $notificationsEnabled)
                        .tint(Theme.brand)
                        .labelsHidden()
                }

                Divider()
                    .padding(.leading, 52)

                settingsRow(
                    icon: "speaker.wave.2.fill",
                    title: "Sound Effects",
                    color: Theme.success
                ) {
                    Toggle("", isOn: $soundEffectsEnabled)
                        .tint(Theme.brand)
                        .labelsHidden()
                }
            }
            .padding(.vertical, Theme.spacingXS)
            .cardStyle()
        }
    }

    private func settingsRow<Trailing: View>(
        icon: String,
        title: String,
        color: Color,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }

            Text(title)
                .font(.bodyLarge)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            Spacer()

            trailing()
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, 10)
    }

    // MARK: - Badges Section

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Text("Badges")
                    .font(.headingSmall)
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))

                Spacer()

                let earned = badges.filter(\.isEarned).count
                Text("\(earned)/\(badges.count)")
                    .font(.bodySmall)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
            }

            if isLoadingBadges {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: Theme.cardRadius)
                            .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                            .frame(height: 100)
                            .shimmer()
                    }
                }
            } else if badges.isEmpty {
                emptyBadgesPlaceholder
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    ForEach(badges) { badge in
                        badgeCell(badge)
                    }
                }
            }
        }
    }

    private func badgeCell(_ badge: Badge) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        badge.isEarned
                            ? Theme.warning.opacity(0.15)
                            : Theme.bgSurfaceAdaptive(for: colorScheme)
                    )
                    .frame(width: 52, height: 52)

                if badge.isEarned {
                    Text(badge.icon)
                        .font(.system(size: 24))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.textSecondary(for: colorScheme).opacity(0.5))
                }
            }

            Text(badge.name)
                .font(.nunito(11, weight: .semibold))
                .foregroundStyle(
                    badge.isEarned
                        ? Theme.textPrimary(for: colorScheme)
                        : Theme.textSecondary(for: colorScheme).opacity(0.6)
                )
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 28)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingSM)
        .opacity(badge.isEarned ? 1 : 0.6)
    }

    private var emptyBadgesPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "medal")
                .font(.system(size: 32))
                .foregroundStyle(Theme.textSecondary(for: colorScheme).opacity(0.4))

            Text("Complete lessons to earn badges!")
                .font(.bodySmall)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingLG)
    }

    // MARK: - Sign Out Button

    private var signOutButton: some View {
        Button {
            showSignOutConfirm = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
            }
            .font(.nunito(16, weight: .semibold))
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.buttonRadius, style: .continuous)
                    .strokeBorder(.red.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.top, Theme.spacingSM)
    }

    // MARK: - Helpers

    private var userInitial: String {
        let name = authService.currentUser?.name ?? "?"
        return String(name.prefix(1)).uppercased()
    }

    private var xpProgress: CGFloat {
        guard let user = authService.currentUser else { return 0 }
        return CGFloat(user.levelProgress.progress)
    }

    private var formattedXP: String {
        guard let xp = authService.currentUser?.totalXP else { return "0" }
        if xp >= 1000 {
            let k = Double(xp) / 1000.0
            return String(format: "%.1fk", k)
        }
        return "\(xp)"
    }

    // MARK: - Data Loading

    private func loadData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await fetchBadges() }
            group.addTask { await fetchReviewStats() }
        }
    }

    private func refreshData() async {
        do {
            try await authService.fetchCurrentUser()
        } catch {
            // Silently handle refresh errors
        }
        await loadData()
    }

    private func fetchBadges() async {
        // Badges are fetched from user profile API when available.
        // For now, this is a placeholder -- the API integration
        // will populate this once the endpoint exists.
        isLoadingBadges = false
    }

    private func fetchReviewStats() async {
        do {
            reviewStats = try await reviewService.fetchStats()
        } catch {
            // Stats are optional; fail silently
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(AuthService())
}
