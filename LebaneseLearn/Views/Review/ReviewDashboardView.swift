import SwiftUI
import SwiftData

struct ReviewDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allCards: [SRSCardRecord]
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    @State private var isSeedingPhase: Int?

    private var dueNow: [SRSCardRecord] {
        allCards.filter { $0.nextReviewAt <= .now }
    }

    private var mastered: [SRSCardRecord] {
        allCards.filter { $0.interval >= 21 }
    }

    private var learning: [SRSCardRecord] {
        allCards.filter { $0.interval > 0 && $0.interval < 21 }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Stats cards
                statsSection
                    .fadeUpAnimation()

                // Start review button
                reviewButton
                    .fadeUpAnimation(delay: 0.1)

                // Seed cards section
                seedCardsSection
                    .fadeUpAnimation(delay: 0.2)
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingMD)
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Theme.spacingSM),
                GridItem(.flexible(), spacing: Theme.spacingSM),
            ],
            spacing: Theme.spacingSM
        ) {
            StatCard(
                icon: "rectangle.stack.fill",
                title: "Total Cards",
                value: "\(allCards.count)",
                tint: Theme.electricBlue
            )

            StatCard(
                icon: "clock.badge.exclamationmark.fill",
                title: "Due Now",
                value: "\(dueNow.count)",
                tint: Theme.brand
            )

            StatCard(
                icon: "checkmark.seal.fill",
                title: "Mastered",
                value: "\(mastered.count)",
                tint: Theme.vividGreen
            )

            StatCard(
                icon: "book.fill",
                title: "Learning",
                value: "\(learning.count)",
                tint: Theme.goldenYellow
            )
        }
    }

    // MARK: - Review Button

    @ViewBuilder
    private var reviewButton: some View {
        if dueNow.isEmpty {
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Theme.vividGreen)
                Text("All caught up! Come back later.")
                    .font(.bodyLarge)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .glassCard(tint: Theme.vividGreen)
        } else {
            NavigationLink {
                ReviewSessionView()
            } label: {
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: "play.fill")
                    Text("Start Review (\(dueNow.count) cards)")
                }
                .font(.headingSmall)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .glassButtonProminent(tint: Theme.brand)
            }
        }
    }

    // MARK: - Seed Cards Section

    private var seedCardsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: "plus.rectangle.on.rectangle")
                    .foregroundStyle(Theme.electricBlue)
                Text("Add Flashcards by Phase")
                    .font(.headingSmall)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Theme.spacingSM),
                    GridItem(.flexible(), spacing: Theme.spacingSM),
                    GridItem(.flexible(), spacing: Theme.spacingSM),
                ],
                spacing: Theme.spacingSM
            ) {
                ForEach(1...6, id: \.self) { phaseId in
                    Button {
                        seedPhase(phaseId)
                    } label: {
                        VStack(spacing: 6) {
                            if isSeedingPhase == phaseId {
                                ProgressView()
                                    .tint(Theme.electricBlue)
                                    .frame(height: 24)
                            } else {
                                Image(systemName: "\(phaseId).circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Theme.electricBlue)
                            }

                            Text("Phase \(phaseId)")
                                .font(.bodySmall)
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.spacingSM)
                        .glassEffect(.regular.tint(Theme.electricBlue), in: .rect(cornerRadius: Theme.badgeRadius))
                    }
                    .buttonStyle(.plain)
                    .disabled(isSeedingPhase != nil)
                }
            }
        }
    }

    // MARK: - Actions

    private func seedPhase(_ phaseId: Int) {
        isSeedingPhase = phaseId
        let vocab = ContentManager.shared.vocab(for: phaseId)
        SRSEngine.seedCards(from: vocab, phaseId: phaseId, context: modelContext)
        isSeedingPhase = nil
    }
}

#Preview {
    NavigationStack {
        ReviewDashboardView()
    }
    .modelContainer(for: [SRSCardRecord.self, UserProfile.self], inMemory: true)
}
