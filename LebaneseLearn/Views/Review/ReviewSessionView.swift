import SwiftUI

// MARK: - Review Session View

struct ReviewSessionView: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var cards: [SRSCard] = []
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var sessionComplete = false
    @State private var totalXPEarned = 0
    @State private var cardsReviewed = 0

    // Animation states
    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1
    @State private var showXPPopup = false
    @State private var lastXPEarned = 0
    @State private var xpPopupOffset: CGFloat = 0
    @State private var xpPopupOpacity: Double = 0
    @State private var isTransitioning = false

    private let reviewService = ReviewService.shared

    var body: some View {
        ZStack {
            Theme.bgMainAdaptive(for: colorScheme)
                .ignoresSafeArea()

            if isLoading {
                loadingView
            } else if sessionComplete {
                sessionCompleteView
            } else if cards.isEmpty {
                emptyStateView
            } else if let errorMessage {
                errorView(errorMessage)
            } else {
                sessionContent
            }

            // XP Popup overlay
            if showXPPopup {
                xpPopupView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Review")
                    .font(.headingSmall)
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                }
            }
        }
        .task {
            await loadCards()
        }
    }

    // MARK: - Session Content

    private var sessionContent: some View {
        VStack(spacing: Theme.spacingLG) {
            // Progress bar
            progressBar

            Spacer()

            // Flashcard
            flashcard

            Spacer()

            // Rating buttons (shown after flip)
            if isFlipped {
                ratingButtons
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(Theme.spacingMD)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Card \(currentIndex + 1) of \(cards.count)")
                    .font(.bodySmall)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
                Spacer()
                Text("\(cardsReviewed) reviewed")
                    .font(.bodySmall)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Theme.bgSurfaceAdaptive(for: colorScheme))

                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Theme.success, Theme.success.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressFraction)
                        .animation(.easeInOut(duration: 0.3), value: progressFraction)
                }
            }
            .frame(height: 8)
        }
    }

    private var progressFraction: CGFloat {
        guard !cards.isEmpty else { return 0 }
        return CGFloat(currentIndex) / CGFloat(cards.count)
    }

    // MARK: - Flashcard

    private var flashcard: some View {
        let currentCard = cards[currentIndex]

        return ZStack {
            // Card Back (English + pronunciation)
            cardBack(currentCard)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .opacity(isFlipped ? 1 : 0)

            // Card Front (Arabic)
            cardFront(currentCard)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .opacity(isFlipped ? 0 : 1)
        }
        .offset(x: cardOffset)
        .opacity(cardOpacity)
        .onTapGesture {
            guard !isFlipped, !isTransitioning else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isFlipped = true
            }
        }
    }

    private func cardFront(_ card: SRSCard) -> some View {
        VStack(spacing: Theme.spacingMD) {
            Spacer()

            Text(card.front)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingLG)

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "hand.tap.fill")
                    .font(.caption)
                Text("Tap to reveal")
                    .font(.bodySmall)
            }
            .foregroundStyle(Theme.textSecondary(for: colorScheme).opacity(0.6))
            .padding(.bottom, Theme.spacingMD)
        }
        .frame(maxWidth: .infinity, maxHeight: 340)
        .cardStyle()
    }

    private func cardBack(_ card: SRSCard) -> some View {
        VStack(spacing: Theme.spacingMD) {
            Spacer()

            Text(card.back)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingLG)

            if let pronunciation = card.pronunciation, !pronunciation.isEmpty {
                Text(pronunciation)
                    .font(.nunito(18, weight: .medium))
                    .foregroundStyle(Theme.xpPurple)
                    .italic()
            }

            if let category = card.category, !category.isEmpty {
                Text(category)
                    .font(.bodySmall)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Theme.bgSurfaceAdaptive(for: colorScheme))
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 340)
        .cardStyle()
    }

    // MARK: - Rating Buttons

    private var ratingButtons: some View {
        HStack(spacing: Theme.spacingSM) {
            ratingButton(label: "Again", rating: 1, color: Theme.brand, icon: "arrow.uturn.backward")
            ratingButton(label: "Hard", rating: 2, color: Theme.warning, icon: "tortoise.fill")
            ratingButton(label: "Good", rating: 3, color: Theme.success, icon: "hand.thumbsup.fill")
            ratingButton(label: "Easy", rating: 4, color: Theme.info, icon: "bolt.fill")
        }
    }

    private func ratingButton(label: String, rating: Int, color: Color, icon: String) -> some View {
        Button {
            Task {
                await submitRating(rating)
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)

                Text(label)
                    .font(.nunito(12, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius, style: .continuous))
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .disabled(isTransitioning)
    }

    // MARK: - XP Popup

    private var xpPopupView: some View {
        Text("+\(lastXPEarned) XP")
            .font(.nunito(22, weight: .bold))
            .foregroundStyle(Theme.xpPurple)
            .offset(y: xpPopupOffset)
            .opacity(xpPopupOpacity)
    }

    // MARK: - Session Complete

    private var sessionCompleteView: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()

            Image(systemName: "party.popper.fill")
                .font(.system(size: 72))
                .foregroundStyle(Theme.warning)

            Text("Session Complete!")
                .font(.headingLarge)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            VStack(spacing: Theme.spacingMD) {
                HStack(spacing: Theme.spacingLG) {
                    completionStat(
                        icon: "rectangle.stack.fill",
                        label: "Cards Reviewed",
                        value: "\(cardsReviewed)",
                        color: Theme.info
                    )
                    completionStat(
                        icon: "star.fill",
                        label: "XP Earned",
                        value: "+\(totalXPEarned)",
                        color: Theme.xpPurple
                    )
                }
            }
            .padding(Theme.spacingLG)
            .cardStyle()

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Back to Dashboard")
                    .primaryButton()
            }
        }
        .padding(Theme.spacingMD)
        .fadeUpAnimation()
    }

    private func completionStat(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)

            Text(value)
                .font(.headingMedium)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            Text(label)
                .font(.bodySmall)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Theme.spacingMD) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.success)

            Text("No Cards Due")
                .font(.headingMedium)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            Text("You're all caught up! Check back later for more reviews.")
                .font(.bodyLarge)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingXL)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Back to Dashboard")
                    .primaryButton()
            }
        }
        .padding(Theme.spacingMD)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: Theme.spacingMD) {
            ProgressView()
                .tint(Theme.brand)
                .scaleEffect(1.3)

            Text("Loading flashcards...")
                .font(.bodyLarge)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.warning)

            Text(message)
                .font(.bodyMedium)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)

            Button {
                Task { await loadCards() }
            } label: {
                Text("Retry")
                    .primaryButton()
            }
        }
        .padding(Theme.spacingXL)
    }

    // MARK: - Data Loading

    private func loadCards() async {
        isLoading = true
        errorMessage = nil

        do {
            cards = try await reviewService.fetchDueCards()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Submit Rating

    private func submitRating(_ rating: Int) async {
        guard currentIndex < cards.count else { return }
        isTransitioning = true

        let card = cards[currentIndex]

        do {
            let response = try await reviewService.submitReview(cardId: card.id, rating: rating)
            cardsReviewed += 1
            totalXPEarned += response.xpEarned
            lastXPEarned = response.xpEarned

            // Show XP popup
            showXPAnimation()

            // Wait for XP popup to show, then transition card
            try? await Task.sleep(for: .milliseconds(400))

            // Slide current card out to the left
            withAnimation(.easeInOut(duration: 0.25)) {
                cardOffset = -400
                cardOpacity = 0
            }

            try? await Task.sleep(for: .milliseconds(250))

            // Check if session is complete
            if currentIndex + 1 >= cards.count {
                withAnimation(.easeInOut(duration: 0.3)) {
                    sessionComplete = true
                }
            } else {
                // Prepare next card: position offscreen right
                isFlipped = false
                cardOffset = 400
                cardOpacity = 0
                currentIndex += 1

                // Slide new card in from the right
                withAnimation(.easeOut(duration: 0.25)) {
                    cardOffset = 0
                    cardOpacity = 1
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isTransitioning = false
    }

    private func showXPAnimation() {
        xpPopupOffset = 0
        xpPopupOpacity = 1
        showXPPopup = true

        withAnimation(.easeOut(duration: 0.8)) {
            xpPopupOffset = -80
            xpPopupOpacity = 0
        }

        // Remove popup after animation
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(800))
            showXPPopup = false
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReviewSessionView()
    }
    .environment(AuthService())
}
