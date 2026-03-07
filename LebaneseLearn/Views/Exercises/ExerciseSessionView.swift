import SwiftUI
import SwiftData

struct ExerciseSessionView: View {
    let exerciseSet: ExerciseSet

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    // MARK: - State

    @State private var currentIndex = 0
    @State private var score = 0
    @State private var answers: [Bool] = []
    @State private var showingResult = false
    @State private var selectedOptionIndex: Int?
    @State private var fillAnswer = ""
    @State private var hasSubmitted = false
    @State private var isCorrect: Bool?
    @State private var matchedPairs: Set<String> = []
    @State private var selectedMatchArabic: String?
    @State private var sessionStartTime = Date()

    // MARK: - Computed

    private var totalQuestions: Int {
        switch exerciseSet.type {
        case .multipleChoice:
            return exerciseSet.questions?.count ?? 0
        case .fillBlank:
            return exerciseSet.fillBlanks?.count ?? 0
        case .matching:
            return exerciseSet.matchingPairs?.count ?? 0
        default:
            return 0
        }
    }

    private var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentIndex) / Double(totalQuestions)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            progressBar
                .padding(.horizontal, Theme.spacingMD)
                .padding(.top, Theme.spacingSM)

            if showingResult {
                resultView
            } else {
                ScrollView {
                    VStack(spacing: Theme.spacingLG) {
                        Text("Question \(currentIndex + 1) of \(totalQuestions)")
                            .font(.bodySmall)
                            .foregroundStyle(.secondary)
                            .padding(.top, Theme.spacingMD)

                        exerciseContent
                    }
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.bottom, 100)
                }

                bottomAction
            }
        }
        .navigationTitle(exerciseSet.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .glassEffect(in: .circle)
                }
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.brand.opacity(0.15))
                    .frame(height: 8)

                Capsule()
                    .fill(Theme.brand)
                    .frame(width: max(geometry.size.width * progress, 8), height: 8)
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: 8)
    }

    // MARK: - Exercise Content

    @ViewBuilder
    private var exerciseContent: some View {
        switch exerciseSet.type {
        case .multipleChoice:
            multipleChoiceContent
        case .fillBlank:
            fillBlankContent
        case .matching:
            matchingContent
        default:
            Text("Exercise type not supported")
                .font(.bodyLarge)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Multiple Choice

    @ViewBuilder
    private var multipleChoiceContent: some View {
        if let questions = exerciseSet.questions, currentIndex < questions.count {
            let question = questions[currentIndex]

            // Prompt
            VStack(spacing: Theme.spacingSM) {
                Text(question.prompt)
                    .font(.headingMedium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                if let arabic = question.promptArabic {
                    Text(arabic)
                        .font(.nunito(22, weight: .bold))
                        .foregroundStyle(Theme.electricBlue)
                        .speakable(arabic)
                }
            }
            .glassCard()

            // Options
            VStack(spacing: Theme.spacingSM) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button {
                        guard !hasSubmitted else { return }
                        selectedOptionIndex = index
                    } label: {
                        HStack {
                            Text(option)
                                .font(.nunito(16, weight: .medium))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            if hasSubmitted {
                                if index == question.correctIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.vividGreen)
                                } else if index == selectedOptionIndex {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Theme.brand)
                                }
                            } else if index == selectedOptionIndex {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundStyle(Theme.brand)
                            }
                        }
                        .padding(Theme.spacingMD)
                        .glassEffect(
                            hasSubmitted
                                ? (index == question.correctIndex
                                    ? .regular.tint(Theme.vividGreen)
                                    : (index == selectedOptionIndex
                                        ? .regular.tint(Theme.brand)
                                        : .regular))
                                : (index == selectedOptionIndex
                                    ? .regular.tint(Theme.brand)
                                    : .regular),
                            in: .rect(cornerRadius: Theme.buttonRadius)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(hasSubmitted)
                }
            }

            // Explanation
            if hasSubmitted, let explanation = question.explanation {
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Theme.goldenYellow)
                    Text(explanation)
                        .font(.bodyMedium)
                        .foregroundStyle(.secondary)
                }
                .glassCard(tint: Theme.goldenYellow)
            }
        }
    }

    // MARK: - Fill in the Blank

    @ViewBuilder
    private var fillBlankContent: some View {
        if let blanks = exerciseSet.fillBlanks, currentIndex < blanks.count {
            let question = blanks[currentIndex]

            // Sentence with blank
            VStack(spacing: Theme.spacingSM) {
                Text(question.sentence.replacingOccurrences(of: question.blank, with: "______"))
                    .font(.headingMedium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                if let hint = question.hint {
                    Text("Hint: \(hint)")
                        .font(.bodySmall)
                        .foregroundStyle(Theme.brightPurple)
                }
            }
            .glassCard()

            // Text input
            TextField("Type your answer", text: $fillAnswer)
                .font(.bodyLarge)
                .multilineTextAlignment(.center)
                .padding(Theme.spacingMD)
                .glassEffect(
                    hasSubmitted
                        ? (isCorrect == true
                            ? .regular.tint(Theme.vividGreen)
                            : .regular.tint(Theme.brand))
                        : .regular,
                    in: .rect(cornerRadius: Theme.inputRadius)
                )
                .disabled(hasSubmitted)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if hasSubmitted, isCorrect == false {
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Theme.vividGreen)
                    Text("Correct answer: \(question.answer)")
                        .font(.bodyMedium)
                        .foregroundStyle(Theme.vividGreen)
                }
                .glassCard(tint: Theme.vividGreen)
            }
        }
    }

    // MARK: - Matching

    @ViewBuilder
    private var matchingContent: some View {
        if let pairs = exerciseSet.matchingPairs {
            Text("Match the Arabic with the English")
                .font(.headingSmall)
                .foregroundStyle(.primary)
                .glassCard()

            let shuffledEnglish = pairs.map(\.english).shuffled()

            VStack(spacing: Theme.spacingSM) {
                ForEach(pairs, id: \.arabic) { pair in
                    HStack(spacing: Theme.spacingMD) {
                        // Arabic side
                        Button {
                            selectedMatchArabic = pair.arabic
                        } label: {
                            Text(pair.arabic)
                                .font(.nunito(18, weight: .bold))
                                .foregroundStyle(matchedPairs.contains(pair.arabic) ? Theme.vividGreen : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.spacingSM)
                                .glassEffect(
                                    selectedMatchArabic == pair.arabic
                                        ? .regular.tint(Theme.brand)
                                        : (matchedPairs.contains(pair.arabic)
                                            ? .regular.tint(Theme.vividGreen)
                                            : .regular),
                                    in: .rect(cornerRadius: Theme.badgeRadius)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(matchedPairs.contains(pair.arabic))
                        .speakable(pair.arabic)
                    }
                }
            }

            VStack(spacing: Theme.spacingSM) {
                ForEach(shuffledEnglish, id: \.self) { english in
                    Button {
                        checkMatch(english: english)
                    } label: {
                        Text(english)
                            .font(.bodyLarge)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(Theme.spacingSM)
                            .glassEffect(in: .rect(cornerRadius: Theme.badgeRadius))
                    }
                    .buttonStyle(.plain)
                    .disabled(matchedPairs.contains(matchedArabicFor(english: english) ?? ""))
                }
            }
        }
    }

    // MARK: - Bottom Action

    private var bottomAction: some View {
        VStack {
            if hasSubmitted {
                Button {
                    goToNext()
                } label: {
                    Text(currentIndex < totalQuestions - 1 ? "Next" : "See Results")
                        .font(.headingSmall)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .glassButtonProminent(tint: Theme.brand)
            } else {
                Button {
                    submitAnswer()
                } label: {
                    Text("Check")
                        .font(.headingSmall)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .glassButtonProminent(tint: Theme.brand)
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1 : 0.5)
            }
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.bottom, Theme.spacingMD)
    }

    private var canSubmit: Bool {
        switch exerciseSet.type {
        case .multipleChoice:
            return selectedOptionIndex != nil
        case .fillBlank:
            return !fillAnswer.trimmingCharacters(in: .whitespaces).isEmpty
        case .matching:
            return matchedPairs.count == (exerciseSet.matchingPairs?.count ?? 0)
        default:
            return false
        }
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()

            Image(systemName: accuracyIcon)
                .font(.system(size: 64))
                .foregroundStyle(accuracyColor)

            Text("Session Complete!")
                .font(.headingLarge)

            Text("\(score)/\(totalQuestions)")
                .font(.nunito(48, weight: .bold))
                .foregroundStyle(accuracyColor)

            let accuracy = totalQuestions > 0 ? Int(Double(score) / Double(totalQuestions) * 100) : 0
            Text("\(accuracy)% Accuracy")
                .font(.headingSmall)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Theme.brightPurple)
                Text("+\(score * 10) XP")
                    .font(.headingSmall)
                    .foregroundStyle(Theme.brightPurple)
            }
            .xpBadge()

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Continue")
                    .font(.headingSmall)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .glassButtonProminent(tint: Theme.brand)
            .padding(.horizontal, Theme.spacingMD)
            .padding(.bottom, Theme.spacingLG)
        }
    }

    private var accuracyIcon: String {
        let accuracy = totalQuestions > 0 ? Double(score) / Double(totalQuestions) : 0
        if accuracy >= 0.9 { return "trophy.fill" }
        if accuracy >= 0.7 { return "star.fill" }
        if accuracy >= 0.5 { return "hand.thumbsup.fill" }
        return "arrow.clockwise"
    }

    private var accuracyColor: Color {
        let accuracy = totalQuestions > 0 ? Double(score) / Double(totalQuestions) : 0
        if accuracy >= 0.9 { return Theme.goldenYellow }
        if accuracy >= 0.7 { return Theme.vividGreen }
        if accuracy >= 0.5 { return Theme.electricBlue }
        return .secondary
    }

    // MARK: - Actions

    private func submitAnswer() {
        switch exerciseSet.type {
        case .multipleChoice:
            guard let questions = exerciseSet.questions,
                  currentIndex < questions.count,
                  let selected = selectedOptionIndex else { return }
            let correct = selected == questions[currentIndex].correctIndex
            isCorrect = correct
            if correct { score += 1 }
            answers.append(correct)

        case .fillBlank:
            guard let blanks = exerciseSet.fillBlanks,
                  currentIndex < blanks.count else { return }
            let question = blanks[currentIndex]
            let userAnswer = fillAnswer.trimmingCharacters(in: .whitespaces).lowercased()
            let correct = userAnswer == question.answer.lowercased()
                || (question.acceptableAnswers?.contains(where: { $0.lowercased() == userAnswer }) ?? false)
            isCorrect = correct
            if correct { score += 1 }
            answers.append(correct)

        case .matching:
            let correct = matchedPairs.count == (exerciseSet.matchingPairs?.count ?? 0)
            isCorrect = correct
            if correct { score += 1 }
            answers.append(correct)

        default:
            break
        }

        hasSubmitted = true
    }

    private func goToNext() {
        if currentIndex < totalQuestions - 1 {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentIndex += 1
                resetAnswerState()
            }
        } else {
            completeSession()
            withAnimation(.easeInOut(duration: 0.35)) {
                showingResult = true
            }
        }
    }

    private func resetAnswerState() {
        selectedOptionIndex = nil
        fillAnswer = ""
        hasSubmitted = false
        isCorrect = nil
        selectedMatchArabic = nil
        matchedPairs = []
    }

    private func completeSession() {
        let timeSpent = Int(Date().timeIntervalSince(sessionStartTime))
        let result = ExerciseResultRecord(
            phaseId: exerciseSet.phaseId,
            exerciseSetId: exerciseSet.id,
            exerciseType: exerciseSet.type.rawValue,
            score: totalQuestions > 0 ? Int(Double(score) / Double(totalQuestions) * 100) : 0,
            totalQuestions: totalQuestions,
            correctAnswers: score,
            timeSpentSeconds: timeSpent
        )
        modelContext.insert(result)

        if let profile {
            XPEngine.awardXP(
                amount: score * 10,
                source: "exercise",
                sourceId: exerciseSet.id,
                profile: profile,
                context: modelContext
            )
            XPEngine.updateStreak(profile: profile)
        }

        try? modelContext.save()
    }

    private func checkMatch(english: String) {
        guard let arabic = selectedMatchArabic,
              let pairs = exerciseSet.matchingPairs else { return }

        if let pair = pairs.first(where: { $0.arabic == arabic && $0.english == english }) {
            matchedPairs.insert(pair.arabic)
        }

        selectedMatchArabic = nil
    }

    private func matchedArabicFor(english: String) -> String? {
        exerciseSet.matchingPairs?.first(where: { $0.english == english })?.arabic
    }
}
