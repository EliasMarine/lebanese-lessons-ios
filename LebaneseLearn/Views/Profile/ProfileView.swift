import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    // API Key state
    @State private var elevenLabsAPIKey = ""
    @State private var elevenLabsVoiceId = ""
    @State private var aiAPIKey = ""
    @State private var selectedGoal = 10
    @State private var hasLoadedKeys = false

    private let goalOptions = [5, 10, 15, 20, 30]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Avatar and info
                avatarSection
                    .fadeUpAnimation()

                // Level progress ring
                levelProgressSection
                    .fadeUpAnimation(delay: 0.05)

                // Stats grid
                statsGrid
                    .fadeUpAnimation(delay: 0.1)

                // Study goal setting
                studyGoalSection
                    .fadeUpAnimation(delay: 0.15)

                // API settings
                apiSettingsSection
                    .fadeUpAnimation(delay: 0.2)
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.top, Theme.spacingSM)
            .padding(.bottom, Theme.spacingXL)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadKeychainValues()
            if let profile {
                selectedGoal = profile.studyGoalMinutes
            }
        }
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: Theme.spacingSM) {
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
                    .glassEffect(in: .circle)

                Text(String((profile?.name ?? "?").prefix(1)).uppercased())
                    .font(.nunito(40, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text(profile?.name ?? "Learner")
                .font(.headingMedium)

            HStack(spacing: 6) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 12))
                Text("Level \(profile?.level ?? 1) \u{2022} \(profile?.levelTitle ?? "Beginner")")
                    .font(.nunito(13, weight: .semibold))
            }
            .foregroundStyle(Theme.brightPurple)
            .xpBadge()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingLG)
    }

    // MARK: - Level Progress

    private var levelProgressSection: some View {
        HStack(spacing: Theme.spacingLG) {
            ProgressRing(
                progress: levelProgress,
                size: 80,
                lineWidth: 8,
                tint: Theme.brightPurple
            )
            .overlay {
                VStack(spacing: 0) {
                    Text("\(profile?.level ?? 1)")
                        .font(.headingSmall)
                        .foregroundStyle(Theme.brightPurple)
                    Text("Level")
                        .font(.nunito(10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text("XP Progress")
                    .font(.headingSmall)

                Text("\(profile?.currentXPInLevel ?? 0) / \(profile?.xpNeededForLevel ?? 200) XP")
                    .font(.bodyMedium)
                    .foregroundStyle(.secondary)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.brightPurple.opacity(0.2))
                            .frame(height: 8)
                        Capsule()
                            .fill(Theme.brightPurple)
                            .frame(width: geometry.size.width * levelProgress, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .glassCard(tint: Theme.brightPurple)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: Theme.spacingSM
        ) {
            StatCard(
                icon: "star.fill",
                title: "Total XP",
                value: formattedXP,
                tint: Theme.brightPurple
            )

            StatCard(
                icon: "flame.fill",
                title: "Streak",
                value: "\(profile?.streak ?? 0)",
                tint: Theme.sunsetOrange
            )

            StatCard(
                icon: "trophy.fill",
                title: "Longest Streak",
                value: "\(profile?.longestStreak ?? 0)",
                tint: Theme.goldenYellow
            )

            StatCard(
                icon: "calendar",
                title: "Joined",
                value: joinedDate,
                tint: Theme.electricBlue
            )
        }
    }

    // MARK: - Study Goal Section

    private var studyGoalSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("Daily Study Goal")
                .font(.headingSmall)

            HStack(spacing: Theme.spacingSM) {
                ForEach(goalOptions, id: \.self) { minutes in
                    Button {
                        selectedGoal = minutes
                        profile?.studyGoalMinutes = minutes
                        try? modelContext.save()
                    } label: {
                        Text("\(minutes)m")
                            .font(.nunito(14, weight: selectedGoal == minutes ? .bold : .medium))
                            .foregroundStyle(selectedGoal == minutes ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.spacingSM)
                    }
                    .glassEffect(
                        selectedGoal == minutes
                            ? .regular.tint(Theme.brand)
                            : .regular,
                        in: .capsule
                    )
                }
            }
        }
        .glassCard()
    }

    // MARK: - API Settings Section

    private var apiSettingsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: "key.fill")
                    .foregroundStyle(Theme.goldenYellow)
                Text("API Settings")
                    .font(.headingSmall)
            }

            // ElevenLabs API Key
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text("ElevenLabs API Key")
                    .font(.bodySmall)
                    .foregroundStyle(.secondary)
                SecureField("Enter API key", text: $elevenLabsAPIKey)
                    .font(.bodyMedium)
                    .padding(Theme.spacingSM)
                    .glassEffect(in: .rect(cornerRadius: Theme.inputRadius))
                    .onChange(of: elevenLabsAPIKey) { _, newValue in
                        if !newValue.isEmpty {
                            ElevenLabsService.shared.setAPIKey(newValue)
                        }
                    }
            }

            // ElevenLabs Voice ID
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text("ElevenLabs Voice ID")
                    .font(.bodySmall)
                    .foregroundStyle(.secondary)
                TextField("Enter voice ID", text: $elevenLabsVoiceId)
                    .font(.bodyMedium)
                    .padding(Theme.spacingSM)
                    .glassEffect(in: .rect(cornerRadius: Theme.inputRadius))
                    .onChange(of: elevenLabsVoiceId) { _, newValue in
                        if !newValue.isEmpty {
                            ElevenLabsService.shared.setVoiceId(newValue)
                        }
                    }
            }

            // AI API Key
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text("AI API Key")
                    .font(.bodySmall)
                    .foregroundStyle(.secondary)
                SecureField("Enter API key", text: $aiAPIKey)
                    .font(.bodyMedium)
                    .padding(Theme.spacingSM)
                    .glassEffect(in: .rect(cornerRadius: Theme.inputRadius))
                    .onChange(of: aiAPIKey) { _, newValue in
                        if !newValue.isEmpty {
                            AIService.shared.setAPIKey(newValue)
                        }
                    }
            }
        }
        .glassCard()
    }

    // MARK: - Helpers

    private var levelProgress: Double {
        guard let profile, profile.xpNeededForLevel > 0 else { return 0 }
        return Double(profile.currentXPInLevel) / Double(profile.xpNeededForLevel)
    }

    private var formattedXP: String {
        let xp = profile?.totalXP ?? 0
        if xp >= 1000 {
            return String(format: "%.1fk", Double(xp) / 1000.0)
        }
        return "\(xp)"
    }

    private var joinedDate: String {
        guard let date = profile?.createdAt else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func loadKeychainValues() {
        guard !hasLoadedKeys else { return }
        hasLoadedKeys = true
        elevenLabsAPIKey = KeychainHelper.load(key: "com.lebaneselearn.elevenlabs.apiKey") ?? ""
        elevenLabsVoiceId = KeychainHelper.load(key: "com.lebaneselearn.elevenlabs.voiceId") ?? ""
        aiAPIKey = KeychainHelper.load(key: "com.lebaneselearn.ai.apiKey") ?? ""
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .modelContainer(for: UserProfile.self, inMemory: true)
}
