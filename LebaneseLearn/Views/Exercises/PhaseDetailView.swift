import SwiftUI

struct PhaseDetailView: View {
    let phase: Phase

    @State private var selectedTab = "Vocab"

    private var availableTabs: [String] {
        var tabs = ["Vocab", "Exercises", "Dialogues", "Grammar", "Culture"]
        let cm = ContentManager.shared
        if !cm.shadowing(for: phase.id).isEmpty { tabs.append("Shadowing") }
        if !cm.scenarios(for: phase.id).isEmpty { tabs.append("Scenarios") }
        if !cm.verbs(for: phase.id).isEmpty { tabs.append("Verbs") }
        return tabs
    }

    var body: some View {
        VStack(spacing: 0) {
            // Phase header
            phaseHeader

            // Tab picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.spacingSM) {
                    ForEach(availableTabs, id: \.self) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            Text(tab)
                                .font(.nunito(14, weight: selectedTab == tab ? .bold : .medium))
                                .foregroundStyle(selectedTab == tab ? .white : .primary)
                                .padding(.horizontal, Theme.spacingMD)
                                .padding(.vertical, Theme.spacingSM)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedTab == tab ? Theme.brand : Theme.surface)
                        .foregroundStyle(selectedTab == tab ? .white : .primary)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)
            }

            // Tab content
            ScrollView {
                tabContent
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.bottom, Theme.spacingLG)
            }
        }
        .navigationTitle(phase.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: PhaseVocabRoute.self) { route in
            VocabListView(phaseId: route.phaseId)
        }
        .navigationDestination(for: ExerciseSet.self) { exerciseSet in
            ExerciseSessionView(exerciseSet: exerciseSet)
        }
        .navigationDestination(for: Dialogue.self) { dialogue in
            DialogueView(dialogue: dialogue)
        }
        .navigationDestination(for: GrammarRule.self) { rule in
            GrammarDetailView(rule: rule)
        }
    }

    // MARK: - Phase Header

    private var phaseHeader: some View {
        VStack(spacing: Theme.spacingXS) {
            Text(phase.titleArabic)
                .font(.nunito(20, weight: .bold))
                .foregroundStyle(Theme.electricBlue)
            Text(phase.subtitle)
                .font(.bodyMedium)
                .foregroundStyle(.secondary)
            Text(phase.estimatedWeeks)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingSM)
        .background {
            Theme.phaseGradient(for: phase.id).opacity(0.1)
        }
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        let cm = ContentManager.shared

        switch selectedTab {
        case "Vocab":
            let items = cm.vocab(for: phase.id)
            if items.isEmpty {
                emptyState("No vocabulary items yet")
            } else {
                NavigationLink(value: PhaseVocabRoute(phaseId: phase.id)) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundStyle(Theme.electricBlue)
                        Text("View All \(items.count) Words")
                            .font(.headingSmall)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .duoCard(tint: Theme.electricBlue)
                }
                .buttonStyle(.plain)
                .padding(.top, Theme.spacingSM)

                LazyVStack(spacing: Theme.spacingSM) {
                    ForEach(items.prefix(20)) { item in
                        vocabRow(item)
                    }
                }
            }

        case "Exercises":
            let sets = cm.exercises(for: phase.id)
            if sets.isEmpty {
                emptyState("No exercises yet")
            } else {
                LazyVStack(spacing: Theme.spacingSM) {
                    ForEach(sets) { exerciseSet in
                        NavigationLink(value: exerciseSet) {
                            exerciseSetRow(exerciseSet)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, Theme.spacingSM)
            }

        case "Dialogues":
            let items = cm.dialogues(for: phase.id)
            if items.isEmpty {
                emptyState("No dialogues yet")
            } else {
                LazyVStack(spacing: Theme.spacingSM) {
                    ForEach(items) { dialogue in
                        NavigationLink(value: dialogue) {
                            dialogueRow(dialogue)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, Theme.spacingSM)
            }

        case "Grammar":
            let rules = cm.grammar(for: phase.id)
            if rules.isEmpty {
                emptyState("No grammar rules yet")
            } else {
                LazyVStack(spacing: Theme.spacingSM) {
                    ForEach(rules) { rule in
                        NavigationLink(value: rule) {
                            grammarRow(rule)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, Theme.spacingSM)
            }

        case "Culture":
            let notes = cm.culture(for: phase.id)
            if notes.isEmpty {
                emptyState("No culture notes yet")
            } else {
                LazyVStack(spacing: Theme.spacingSM) {
                    ForEach(notes) { note in
                        cultureRow(note)
                    }
                }
                .padding(.top, Theme.spacingSM)
            }

        case "Shadowing":
            let items = cm.shadowing(for: phase.id)
            LazyVStack(spacing: Theme.spacingSM) {
                ForEach(items) { item in
                    shadowingRow(item)
                }
            }
            .padding(.top, Theme.spacingSM)

        case "Scenarios":
            let items = cm.scenarios(for: phase.id)
            LazyVStack(spacing: Theme.spacingSM) {
                ForEach(items) { item in
                    scenarioRow(item)
                }
            }
            .padding(.top, Theme.spacingSM)

        case "Verbs":
            let items = cm.verbs(for: phase.id)
            LazyVStack(spacing: Theme.spacingSM) {
                ForEach(items) { item in
                    verbRow(item)
                }
            }
            .padding(.top, Theme.spacingSM)

        default:
            emptyState("Content not available")
        }
    }

    // MARK: - Row Views

    private func vocabRow(_ item: VocabItem) -> some View {
        HStack(spacing: Theme.spacingMD) {
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(item.arabic)
                    .font(.nunito(20, weight: .bold))
                    .foregroundStyle(.primary)
                    .speakable(item.arabic)

                Text(item.transliteration)
                    .font(.bodyMedium)
                    .foregroundStyle(Theme.brightPurple)
                    .italic()

                Text(item.english)
                    .font(.bodyMedium)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let category = item.category {
                Text(category)
                    .font(.caption)
                    .foregroundStyle(Theme.electricBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .duoChip(tint: Theme.electricBlue)
            }
        }
        .duoCard()
    }

    private func exerciseSetRow(_ set: ExerciseSet) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(systemName: exerciseTypeIcon(set.type))
                .font(.title2)
                .foregroundStyle(Theme.vividGreen)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(set.title)
                    .font(.headingSmall)
                    .foregroundStyle(.primary)

                Text(exerciseTypeLabel(set.type))
                    .font(.caption)
                    .foregroundStyle(Theme.vividGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .duoChip(tint: Theme.vividGreen)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .duoCard()
    }

    private func dialogueRow(_ dialogue: Dialogue) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.title2)
                .foregroundStyle(Theme.hotPink)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(dialogue.title)
                    .font(.headingSmall)
                    .foregroundStyle(.primary)

                Text("\(dialogue.lines.count) lines")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .duoCard()
    }

    private func grammarRow(_ rule: GrammarRule) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(systemName: "text.book.closed.fill")
                .font(.title2)
                .foregroundStyle(Theme.goldenYellow)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(rule.title)
                    .font(.headingSmall)
                    .foregroundStyle(.primary)

                if let tag = rule.tag {
                    Text(tag)
                        .font(.caption)
                        .foregroundStyle(Theme.goldenYellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .duoChip(tint: Theme.goldenYellow)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .duoCard()
    }

    private func cultureRow(_ note: CultureNote) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(systemName: "globe.americas.fill")
                .font(.title2)
                .foregroundStyle(Theme.sunsetOrange)
                .frame(width: 40)

            Text(note.title)
                .font(.headingSmall)
                .foregroundStyle(.primary)

            Spacer()
        }
        .duoCard()
    }

    private func shadowingRow(_ item: ShadowingItem) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(systemName: "mic.fill")
                .font(.title2)
                .foregroundStyle(Theme.brightPurple)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(item.arabic)
                    .font(.nunito(18, weight: .bold))
                    .speakable(item.arabic)
                Text(item.english)
                    .font(.bodySmall)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .duoCard()
    }

    private func scenarioRow(_ item: ScenarioLesson) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(systemName: "theatermasks.fill")
                .font(.title2)
                .foregroundStyle(Theme.hotPink)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(item.title)
                    .font(.headingSmall)
                    .foregroundStyle(.primary)
                Text(item.setting)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .duoCard()
    }

    private func verbRow(_ item: VerbConjugation) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(systemName: "textformat.abc")
                .font(.title2)
                .foregroundStyle(Theme.electricBlue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(item.verbArabic)
                    .font(.nunito(18, weight: .bold))
                    .speakable(item.verbArabic)
                Text("\(item.verb) - \(item.meaning)")
                    .font(.bodySmall)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .duoCard()
    }

    private func emptyState(_ message: String) -> some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(.secondary.opacity(0.4))
            Text(message)
                .font(.bodyMedium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXL)
    }

    // MARK: - Helpers

    private func exerciseTypeIcon(_ type: ExerciseSet.ExerciseContentType) -> String {
        switch type {
        case .multipleChoice: return "list.bullet.circle.fill"
        case .fillBlank: return "text.cursor"
        case .matching: return "arrow.left.arrow.right"
        case .sentenceBuilder: return "text.word.spacing"
        case .dictation: return "ear.fill"
        }
    }

    private func exerciseTypeLabel(_ type: ExerciseSet.ExerciseContentType) -> String {
        switch type {
        case .multipleChoice: return "Multiple Choice"
        case .fillBlank: return "Fill in the Blank"
        case .matching: return "Matching"
        case .sentenceBuilder: return "Sentence Builder"
        case .dictation: return "Dictation"
        }
    }
}

// MARK: - Navigation Routes

struct PhaseVocabRoute: Hashable {
    let phaseId: Int
}

// MARK: - Hashable extensions for navigation

extension ExerciseSet: Hashable {
    static func == (lhs: ExerciseSet, rhs: ExerciseSet) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Dialogue: Hashable {
    static func == (lhs: Dialogue, rhs: Dialogue) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension GrammarRule: Hashable {
    static func == (lhs: GrammarRule, rhs: GrammarRule) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
