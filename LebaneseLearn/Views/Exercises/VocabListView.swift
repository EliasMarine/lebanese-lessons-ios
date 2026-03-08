import SwiftUI

// MARK: - Vocab List View

struct VocabListView: View {
    let phaseId: Int

    @State private var searchText = ""

    private var allVocab: [VocabItem] {
        ContentManager.shared.vocab(for: phaseId)
    }

    private var filteredVocab: [VocabItem] {
        if searchText.isEmpty { return allVocab }
        let query = searchText.lowercased()
        return allVocab.filter {
            $0.arabic.contains(query) ||
            $0.english.lowercased().contains(query) ||
            $0.transliteration.lowercased().contains(query) ||
            ($0.category?.lowercased().contains(query) ?? false)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.spacingSM) {
                // Stats header
                HStack(spacing: Theme.spacingMD) {
                    StatCard(
                        icon: "textformat.abc",
                        title: "Total Words",
                        value: "\(allVocab.count)",
                        tint: Theme.electricBlue
                    )

                    StatCard(
                        icon: "character.textbox",
                        title: "Categories",
                        value: "\(uniqueCategories.count)",
                        tint: Theme.brightPurple
                    )
                }
                .padding(.bottom, Theme.spacingSM)

                ForEach(Array(filteredVocab.enumerated()), id: \.element.id) { index, item in
                    vocabCard(item)
                        .fadeUpAnimation(delay: min(Double(index) * 0.02, 0.5))
                }

                if filteredVocab.isEmpty && !searchText.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingSM)
        }
        .navigationTitle("Phase \(phaseId) Vocabulary")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search words...")
    }

    // MARK: - Vocab Card

    private func vocabCard(_ item: VocabItem) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text(item.arabic)
                        .font(.nunito(24, weight: .bold))
                        .foregroundStyle(.primary)
                        .speakable(item.arabic)

                    Text(item.transliteration)
                        .font(.nunito(16, weight: .medium))
                        .foregroundStyle(Theme.brightPurple)
                        .italic()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: Theme.spacingXS) {
                    if let category = item.category {
                        Text(category)
                            .font(.caption)
                            .foregroundStyle(Theme.electricBlue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .duoChip(tint: Theme.duoBlue)
                    }

                    if let pos = item.partOfSpeech {
                        Text(pos)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Text(item.english)
                .font(.bodyLarge)
                .foregroundStyle(.secondary)

            if let notes = item.notes {
                Text(notes)
                    .font(.bodySmall)
                    .foregroundStyle(.tertiary)
            }

            if let example = item.exampleSentence {
                Divider()
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    HStack(spacing: 4) {
                        Image(systemName: "text.quote")
                            .font(.caption)
                            .foregroundStyle(Theme.sunsetOrange)
                        Text("Example")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(example.arabic)
                        .font(.nunito(16, weight: .medium))
                        .foregroundStyle(.primary)
                        .speakable(example.arabic)

                    Text(example.transliteration)
                        .font(.bodySmall)
                        .foregroundStyle(Theme.brightPurple)
                        .italic()

                    Text(example.english)
                        .font(.bodySmall)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .duoCard()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary.opacity(0.4))
            Text("No words match '\(searchText)'")
                .font(.bodyMedium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXL)
    }

    // MARK: - Helpers

    private var uniqueCategories: Set<String> {
        Set(allVocab.compactMap(\.category))
    }
}

#Preview {
    NavigationStack {
        VocabListView(phaseId: 1)
    }
}
