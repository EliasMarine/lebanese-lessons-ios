import SwiftUI
import SwiftData

struct ReviewSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<SRSCardRecord> { $0.nextReviewAt <= .now })
    private var dueCards: [SRSCardRecord]
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var sessionComplete = false
    @State private var cardsReviewed = 0
    @State private var totalXPEarned = 0

    private var currentCard: SRSCardRecord? {
        guard currentIndex < dueCards.count else { return nil }
        return dueCards[currentIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            if sessionComplete || dueCards.isEmpty {
                sessionCompleteView
            } else if let card = currentCard {
                sessionContent(card: card)
            }
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Session Content

    private func sessionContent(card: SRSCardRecord) -> some View {
        VStack(spacing: Theme.spacingLG) {
            // Progress
            VStack(spacing: 6) {
                HStack {
                    Text("Card \(currentIndex + 1) of \(dueCards.count)")
                        .font(.bodySmall)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(cardsReviewed) reviewed")
                        .font(.bodySmall)
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.vividGreen.opacity(0.2))
                            .frame(height: 8)

                        Capsule()
                            .fill(Theme.vividGreen)
                            .frame(
                                width: dueCards.isEmpty ? 0 : geometry.size.width * CGFloat(currentIndex) / CGFloat(dueCards.count),
                                height: 8
                            )
                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.top, Theme.spacingSM)

            Spacer()

            // Flashcard
            flashcardView(card: card)
                .padding(.horizontal, Theme.spacingMD)

            Spacer()

            // Rating buttons (after flip)
            if isFlipped {
                ratingButtons
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.bottom, Theme.spacingMD)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Flashcard

    private func flashcardView(card: SRSCardRecord) -> some View {
        let vocabItem = lookupVocab(card.vocabItemId)

        return ZStack {
            // Back
            VStack(spacing: Theme.spacingMD) {
                Spacer()

                Text(vocabItem?.english ?? "Unknown")
                    .font(.nunito(28, weight: .bold))
                    .multilineTextAlignment(.center)

                if let transliteration = vocabItem?.transliteration {
                    Text(transliteration)
                        .font(.nunito(18, weight: .medium))
                        .foregroundStyle(Theme.brightPurple)
                        .italic()
                }

                if let pos = vocabItem?.partOfSpeech {
                    Text(pos)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .glassEffect(.regular.tint(Theme.electricBlue), in: .capsule)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            .glassCard(tint: Theme.electricBlue)
            .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .opacity(isFlipped ? 1 : 0)

            // Front
            VStack(spacing: Theme.spacingMD) {
                Spacer()

                Text(vocabItem?.arabic ?? card.vocabItemId)
                    .font(.nunito(42, weight: .bold))
                    .multilineTextAlignment(.center)
                    .speakable(vocabItem?.arabic ?? "")

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.caption)
                    Text("Tap to reveal")
                        .font(.bodySmall)
                }
                .foregroundStyle(.secondary.opacity(0.6))
                .padding(.bottom, Theme.spacingMD)
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            .glassCard()
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .opacity(isFlipped ? 0 : 1)
        }
        .onTapGesture {
            guard !isFlipped else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isFlipped = true
            }
        }
    }

    // MARK: - Rating Buttons

    private var ratingButtons: some View {
        HStack(spacing: Theme.spacingSM) {
            ratingButton(label: "Again", rating: 1, tint: Theme.brand, icon: "arrow.uturn.backward")
            ratingButton(label: "Hard", rating: 2, tint: Theme.sunsetOrange, icon: "tortoise.fill")
            ratingButton(label: "Good", rating: 3, tint: Theme.vividGreen, icon: "hand.thumbsup.fill")
            ratingButton(label: "Easy", rating: 4, tint: Theme.electricBlue, icon: "bolt.fill")
            ratingButton(label: "Perfect", rating: 5, tint: Theme.brightPurple, icon: "star.fill")
        }
    }

    private func ratingButton(label: String, rating: Int, tint: Color, icon: String) -> some View {
        Button {
            submitRating(rating)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.body)
                Text(label)
                    .font(.nunito(11, weight: .semibold))
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: Theme.buttonRadius))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Session Complete

    private var sessionCompleteView: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()

            Image(systemName: "party.popper.fill")
                .font(.system(size: 72))
                .foregroundStyle(Theme.goldenYellow)

            Text("Session Complete!")
                .font(.headingLarge)

            HStack(spacing: Theme.spacingLG) {
                VStack(spacing: Theme.spacingSM) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.title)
                        .foregroundStyle(Theme.electricBlue)
                    Text("\(cardsReviewed)")
                        .font(.headingMedium)
                    Text("Reviewed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: Theme.spacingSM) {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundStyle(Theme.brightPurple)
                    Text("+\(totalXPEarned)")
                        .font(.headingMedium)
                    Text("XP Earned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .glassCard()

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Back to Dashboard")
                    .font(.headingSmall)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .glassButtonProminent(tint: Theme.brand)
            .padding(.horizontal, Theme.spacingMD)
            .padding(.bottom, Theme.spacingLG)
        }
        .padding(Theme.spacingMD)
        .fadeUpAnimation()
    }

    // MARK: - Actions

    private func submitRating(_ rating: Int) {
        guard let card = currentCard else { return }

        SRSEngine.processReview(card: card, rating: rating)
        cardsReviewed += 1

        let xp = rating >= 3 ? 10 : 5
        totalXPEarned += xp

        if let profile {
            XPEngine.awardXP(
                amount: xp,
                source: "review",
                sourceId: card.vocabItemId,
                profile: profile,
                context: modelContext
            )
        }

        try? modelContext.save()

        // Transition to next card
        withAnimation(.easeInOut(duration: 0.3)) {
            isFlipped = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if currentIndex + 1 < dueCards.count {
                withAnimation {
                    currentIndex += 1
                }
            } else {
                withAnimation {
                    sessionComplete = true
                }
            }
        }
    }

    // MARK: - Helpers

    private func lookupVocab(_ id: String) -> VocabItem? {
        ContentManager.shared.allVocab().first(where: { $0.id == id })
    }
}

#Preview {
    NavigationStack {
        ReviewSessionView()
    }
    .modelContainer(for: [SRSCardRecord.self, UserProfile.self, XPEntry.self], inMemory: true)
}
