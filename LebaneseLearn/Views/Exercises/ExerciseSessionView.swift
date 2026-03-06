import SwiftUI
import AVFoundation

// MARK: - Exercise Session View

/// Full exercise session for a lesson. Displays questions sequentially,
/// handles multiple exercise types, provides feedback, and shows results.
struct ExerciseSessionView: View {

    let lesson: Lesson

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var exercises: [Exercise] = []
    @State private var currentIndex = 0
    @State private var isLoading = true
    @State private var errorMessage: String?

    // Answer state
    @State private var selectedOption: String?
    @State private var textAnswer = ""
    @State private var hasSubmitted = false
    @State private var isCorrect: Bool?

    // Session tracking
    @State private var answers: [AnswerResult] = []
    @State private var questionStartTime = Date()
    @State private var isSessionComplete = false
    @State private var sessionResult: ExerciseResultResponse?

    // Feedback animation
    @State private var showFeedback = false
    @State private var shakeOffset: CGFloat = 0

    // XP
    @State private var xpGained: Int?

    private let lessonService = LessonService.shared

    // MARK: - Computed

    private var currentExercise: Exercise? {
        guard currentIndex < exercises.count else { return nil }
        return exercises[currentIndex]
    }

    private var progress: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(currentIndex) / Double(exercises.count)
    }

    private var correctCount: Int {
        answers.filter(\.correct).count
    }

    private var accuracy: Int {
        guard !answers.isEmpty else { return 0 }
        return Int((Double(correctCount) / Double(answers.count)) * 100)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Theme.bgMainAdaptive(for: colorScheme)
                .ignoresSafeArea()

            if isLoading {
                loadingView
            } else if let errorMessage {
                errorView(errorMessage)
            } else if isSessionComplete {
                sessionCompleteView
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9)),
                        removal: .opacity
                    ))
            } else if let exercise = currentExercise {
                exerciseContent(exercise)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }

            // Feedback overlay
            if showFeedback {
                feedbackOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                        .frame(width: 32, height: 32)
                        .background(Theme.bgSurfaceAdaptive(for: colorScheme))
                        .clipShape(Circle())
                }
            }

            ToolbarItem(placement: .principal) {
                Text(lesson.title)
                    .font(.headingSmall)
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))
                    .lineLimit(1)
            }
        }
        .xpPopup(amount: $xpGained)
        .task {
            await loadExercises()
        }
    }

    // MARK: - Exercise Content

    private func exerciseContent(_ exercise: Exercise) -> some View {
        VStack(spacing: 0) {
            // Progress bar
            progressBar
                .padding(.horizontal, Theme.spacingMD)
                .padding(.top, Theme.spacingSM)

            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    // Question counter
                    Text("Question \(currentIndex + 1) of \(exercises.count)")
                        .font(.bodySmall)
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                        .padding(.top, Theme.spacingMD)

                    // Prompt area
                    promptArea(exercise)

                    // Answer area (changes by type)
                    answerArea(exercise)
                        .offset(x: shakeOffset)
                }
                .padding(.horizontal, Theme.spacingMD)
                .padding(.bottom, 100) // Space for button
            }

            // Bottom action button
            bottomButton
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.brand.opacity(0.15))
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Theme.brand, Theme.brand.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(geometry.size.width * progress, 8),
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: 8)
    }

    // MARK: - Prompt Area

    private func promptArea(_ exercise: Exercise) -> some View {
        VStack(spacing: Theme.spacingSM) {
            // Exercise type label
            Text(exerciseTypeLabel(exercise.type))
                .font(.caption)
                .foregroundStyle(Theme.brand)
                .textCase(.uppercase)
                .tracking(1)

            // Main prompt
            Text(exercise.prompt)
                .font(.headingMedium)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            // Arabic prompt (if available)
            if let promptAr = exercise.promptAr, !promptAr.isEmpty {
                Text(promptAr)
                    .font(.nunito(24, weight: .semibold))
                    .foregroundStyle(Theme.info)
                    .multilineTextAlignment(.center)
                    .environment(\.layoutDirection, .rightToLeft)
            }
        }
        .padding(Theme.spacingLG)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    // MARK: - Answer Area

    @ViewBuilder
    private func answerArea(_ exercise: Exercise) -> some View {
        switch exercise.type {
        case .multipleChoice:
            multipleChoiceArea(exercise)
        case .fillBlank:
            textInputArea(placeholder: "Type the missing word...")
        case .translate:
            textInputArea(placeholder: "Type your translation...")
        case .listening:
            listeningArea(exercise)
        case .matching:
            textInputArea(placeholder: "Type your answer...")
        }
    }

    // MARK: - Multiple Choice

    private func multipleChoiceArea(_ exercise: Exercise) -> some View {
        VStack(spacing: Theme.spacingSM) {
            ForEach(exercise.options ?? [], id: \.self) { option in
                Button {
                    guard !hasSubmitted else { return }
                    selectedOption = option
                } label: {
                    HStack {
                        Text(option)
                            .font(.nunito(16, weight: .medium))
                            .foregroundStyle(optionTextColor(option, exercise: exercise))
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if hasSubmitted {
                            if option == exercise.correctAnswer {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.success)
                            } else if option == selectedOption && option != exercise.correctAnswer {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        } else if option == selectedOption {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(Theme.brand)
                        }
                    }
                    .padding(Theme.spacingMD)
                    .background(optionBackground(option, exercise: exercise))
                    .clipShape(
                        RoundedRectangle(cornerRadius: Theme.buttonRadius, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.buttonRadius, style: .continuous)
                            .strokeBorder(
                                optionBorderColor(option, exercise: exercise),
                                lineWidth: selectedOption == option ? 2 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
                .disabled(hasSubmitted)
            }
        }
    }

    private func optionTextColor(_ option: String, exercise: Exercise) -> Color {
        if hasSubmitted {
            if option == exercise.correctAnswer {
                return Theme.success
            } else if option == selectedOption {
                return .red
            }
        }
        return Theme.textPrimary(for: colorScheme)
    }

    private func optionBackground(_ option: String, exercise: Exercise) -> Color {
        if hasSubmitted {
            if option == exercise.correctAnswer {
                return Theme.success.opacity(0.1)
            } else if option == selectedOption && option != exercise.correctAnswer {
                return Color.red.opacity(0.1)
            }
        }
        if option == selectedOption && !hasSubmitted {
            return Theme.brand.opacity(0.08)
        }
        return Theme.bgSurfaceAdaptive(for: colorScheme)
    }

    private func optionBorderColor(_ option: String, exercise: Exercise) -> Color {
        if hasSubmitted {
            if option == exercise.correctAnswer {
                return Theme.success
            } else if option == selectedOption && option != exercise.correctAnswer {
                return .red
            }
        }
        if option == selectedOption && !hasSubmitted {
            return Theme.brand
        }
        return Theme.border(for: colorScheme)
    }

    // MARK: - Text Input Area

    private func textInputArea(placeholder: String) -> some View {
        VStack(spacing: Theme.spacingSM) {
            TextField(placeholder, text: $textAnswer)
                .font(.bodyLarge)
                .padding(Theme.spacingMD)
                .background(Theme.bgSurfaceAdaptive(for: colorScheme))
                .clipShape(
                    RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous)
                        .strokeBorder(
                            hasSubmitted
                                ? (isCorrect == true ? Theme.success : .red)
                                : Theme.border(for: colorScheme),
                            lineWidth: hasSubmitted ? 2 : 1
                        )
                )
                .disabled(hasSubmitted)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onSubmit {
                    if !hasSubmitted && !textAnswer.trimmingCharacters(in: .whitespaces).isEmpty {
                        submitAnswer()
                    }
                }

            if hasSubmitted, let exercise = currentExercise, isCorrect == false {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                    Text("Correct answer: \(exercise.correctAnswer)")
                        .font(.bodySmall)
                }
                .foregroundStyle(Theme.success)
                .padding(.horizontal, Theme.spacingSM)
            }
        }
    }

    // MARK: - Listening Area

    private func listeningArea(_ exercise: Exercise) -> some View {
        VStack(spacing: Theme.spacingMD) {
            // Play audio button
            Button {
                playAudio(url: exercise.audioUrl)
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Theme.info)

                    Text("Tap to Listen")
                        .font(.bodySmall)
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.spacingLG)
                .background(Theme.info.opacity(0.08))
                .clipShape(
                    RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                        .strokeBorder(Theme.info.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            textInputArea(placeholder: "Type what you heard...")
        }
    }

    // MARK: - Bottom Button

    private var bottomButton: some View {
        VStack {
            if hasSubmitted {
                Button {
                    goToNext()
                } label: {
                    Text(currentIndex < exercises.count - 1 ? "Next" : "See Results")
                        .primaryButton()
                }
            } else {
                Button {
                    submitAnswer()
                } label: {
                    Text("Check")
                        .primaryButton()
                }
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1 : 0.5)
            }
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.bottom, Theme.spacingMD)
        .background(
            Theme.bgMainAdaptive(for: colorScheme)
                .shadow(color: Theme.cardShadow(for: colorScheme), radius: 8, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var canSubmit: Bool {
        guard let exercise = currentExercise else { return false }
        switch exercise.type {
        case .multipleChoice:
            return selectedOption != nil
        case .fillBlank, .translate, .listening, .matching:
            return !textAnswer.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    // MARK: - Feedback Overlay

    private var feedbackOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {} // Absorb taps

            VStack(spacing: 8) {
                Image(systemName: isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(isCorrect == true ? Theme.success : .red)
                    .symbolEffect(.bounce, value: showFeedback)

                Text(isCorrect == true ? "Correct!" : "Not quite")
                    .font(.headingMedium)
                    .foregroundStyle(isCorrect == true ? Theme.success : .red)
            }
            .padding(Theme.spacingXL)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }

    // MARK: - Session Complete

    private var sessionCompleteView: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()

            // Trophy
            Image(systemName: accuracyIcon)
                .font(.system(size: 64))
                .foregroundStyle(accuracyColor)
                .symbolEffect(.bounce, value: isSessionComplete)

            Text("Lesson Complete!")
                .font(.headingLarge)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            // Score
            Text("\(correctCount)/\(exercises.count)")
                .font(.nunito(48, weight: .bold))
                .foregroundStyle(accuracyColor)

            // Accuracy
            Text("\(accuracy)% Accuracy")
                .font(.headingSmall)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))

            // XP earned
            if let result = sessionResult {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Theme.xpPurple)
                    Text("+\(result.xpEarned) XP")
                        .font(.headingSmall)
                        .foregroundStyle(Theme.xpPurple)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Theme.xpDim)
                .clipShape(Capsule())
            }

            // Stats row
            HStack(spacing: Theme.spacingLG) {
                VStack(spacing: 4) {
                    Text("\(correctCount)")
                        .font(.headingMedium)
                        .foregroundStyle(Theme.success)
                    Text("Correct")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                }

                VStack(spacing: 4) {
                    Text("\(exercises.count - correctCount)")
                        .font(.headingMedium)
                        .foregroundStyle(.red)
                    Text("Wrong")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                }
            }
            .padding(.top, Theme.spacingSM)

            Spacer()

            // Continue button
            Button {
                dismiss()
            } label: {
                Text("Continue")
                    .primaryButton()
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.bottom, Theme.spacingLG)
        }
        .frame(maxWidth: .infinity)
    }

    private var accuracyIcon: String {
        if accuracy >= 90 { return "trophy.fill" }
        if accuracy >= 70 { return "star.fill" }
        if accuracy >= 50 { return "hand.thumbsup.fill" }
        return "arrow.clockwise"
    }

    private var accuracyColor: Color {
        if accuracy >= 90 { return Theme.warning }
        if accuracy >= 70 { return Theme.success }
        if accuracy >= 50 { return Theme.info }
        return Theme.textSecondary(for: colorScheme)
    }

    // MARK: - Actions

    private func submitAnswer() {
        guard let exercise = currentExercise else { return }

        let userAnswer: String
        switch exercise.type {
        case .multipleChoice:
            userAnswer = selectedOption ?? ""
        case .fillBlank, .translate, .listening, .matching:
            userAnswer = textAnswer.trimmingCharacters(in: .whitespaces)
        }

        let correct = userAnswer.lowercased() == exercise.correctAnswer.lowercased()
        isCorrect = correct
        hasSubmitted = true

        // Record answer
        let timeSpent = Int(Date().timeIntervalSince(questionStartTime))
        let answerResult = AnswerResult(
            exerciseId: exercise.id,
            correct: correct,
            userAnswer: userAnswer,
            timeSpent: timeSpent
        )
        answers.append(answerResult)

        // Show feedback
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showFeedback = true
        }

        // Shake on wrong answer
        if !correct {
            withAnimation(.default) {
                shakeOffset = 10
            }
            withAnimation(.default.delay(0.1)) {
                shakeOffset = -8
            }
            withAnimation(.default.delay(0.2)) {
                shakeOffset = 6
            }
            withAnimation(.default.delay(0.3)) {
                shakeOffset = 0
            }
        }

        // Dismiss feedback after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.3)) {
                showFeedback = false
            }
        }
    }

    private func goToNext() {
        if currentIndex < exercises.count - 1 {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentIndex += 1
                resetAnswerState()
            }
        } else {
            // Session complete
            Task { await completeSession() }
        }
    }

    private func resetAnswerState() {
        selectedOption = nil
        textAnswer = ""
        hasSubmitted = false
        isCorrect = nil
        showFeedback = false
        shakeOffset = 0
        questionStartTime = Date()
    }

    private func completeSession() async {
        let score = Int((Double(correctCount) / Double(exercises.count)) * 100)
        let result = ExerciseResult(
            lessonId: lesson.id,
            score: score,
            totalQuestions: exercises.count,
            accuracy: accuracy,
            answers: answers
        )

        do {
            let response = try await lessonService.submitResult(result: result)
            sessionResult = response
            xpGained = response.xpEarned
        } catch {
            // Even if submission fails, show local results
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isSessionComplete = true
        }
    }

    // MARK: - Audio

    private func playAudio(url: String?) {
        guard let urlString = url, let audioURL = URL(string: urlString) else { return }
        // Use AVAudioPlayer or AVPlayer for remote audio
        let playerItem = AVPlayerItem(url: audioURL)
        let player = AVPlayer(playerItem: playerItem)
        player.play()
    }

    // MARK: - Data Loading

    private func loadExercises() async {
        isLoading = true
        errorMessage = nil

        do {
            exercises = try await lessonService.fetchExercises(lessonId: lesson.id)
            questionStartTime = Date()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Helper Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Theme.brand)
                .scaleEffect(1.2)

            Text("Loading exercises...")
                .font(.bodyMedium)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40))
                .foregroundStyle(Theme.warning)

            Text("Could not load exercises")
                .font(.headingSmall)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            Text(message)
                .font(.bodySmall)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)

            Button("Retry") {
                Task { await loadExercises() }
            }
            .font(.nunito(14, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Theme.brand)
            .clipShape(Capsule())
            .padding(.top, 8)
        }
        .padding(Theme.spacingXL)
    }

    // MARK: - Helpers

    private func exerciseTypeLabel(_ type: ExerciseType) -> String {
        switch type {
        case .multipleChoice: return "Multiple Choice"
        case .fillBlank:      return "Fill in the Blank"
        case .translate:      return "Translate"
        case .listening:      return "Listening"
        case .matching:       return "Matching"
        }
    }
}

// MARK: - Lesson: Hashable (for NavigationDestination)

extension Lesson: Hashable {
    static func == (lhs: Lesson, rhs: Lesson) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ExerciseSessionView(
            lesson: Lesson(
                id: 1,
                phaseId: 1,
                slug: "greetings",
                title: "Basic Greetings",
                description: "Learn common Lebanese greetings",
                order: 1,
                progress: nil
            )
        )
    }
}
