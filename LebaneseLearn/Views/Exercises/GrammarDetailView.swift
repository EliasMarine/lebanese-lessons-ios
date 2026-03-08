import SwiftUI

// MARK: - Grammar Detail View

struct GrammarDetailView: View {
    let rule: GrammarRule

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingLG) {
                // Header
                header
                    .fadeUpAnimation()

                // Explanation
                explanationSection
                    .fadeUpAnimation(delay: 0.1)

                // Examples
                if let examples = rule.examples, !examples.isEmpty {
                    examplesSection(examples)
                        .fadeUpAnimation(delay: 0.15)
                }

                // Table
                if let table = rule.table {
                    tableSection(table)
                        .fadeUpAnimation(delay: 0.2)
                }
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingSM)
        }
        .navigationTitle(rule.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: Theme.spacingSM) {
            Image(systemName: "text.book.closed.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.goldenYellow)

            Text(rule.title)
                .font(.headingMedium)
                .multilineTextAlignment(.center)

            if let tag = rule.tag {
                Text(tag)
                    .font(.bodySmall)
                    .foregroundStyle(Theme.goldenYellow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .glassEffect(.regular.tint(Theme.goldenYellow), in: .capsule)
            }
        }
        .frame(maxWidth: .infinity)
        .glassCard(tint: Theme.goldenYellow)
    }

    // MARK: - Explanation

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            sectionHeader("Explanation", icon: "doc.text.fill", tint: Theme.electricBlue)
            Text(rule.explanation)
                .font(.bodyLarge)
                .foregroundStyle(.primary)
                .lineSpacing(4)
        }
        .glassCard()
    }

    // MARK: - Examples

    private func examplesSection(_ examples: [GrammarExample]) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            sectionHeader("Examples", icon: "text.quote", tint: Theme.vividGreen)

            ForEach(Array(examples.enumerated()), id: \.offset) { _, example in
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text(example.arabic)
                        .font(.nunito(20, weight: .bold))
                        .foregroundStyle(.primary)
                        .speakable(example.arabic)

                    Text(example.transliteration)
                        .font(.nunito(14, weight: .medium))
                        .foregroundStyle(Theme.brightPurple)
                        .italic()

                    Text(example.english)
                        .font(.bodyMedium)
                        .foregroundStyle(.secondary)

                    if let breakdown = example.breakdown {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle.fill")
                                .font(.caption)
                                .foregroundStyle(Theme.electricBlue)
                            Text(breakdown)
                                .font(.bodySmall)
                                .foregroundStyle(Theme.electricBlue)
                        }
                        .padding(.top, 2)
                    }
                }
                .padding(Theme.spacingSM)
                .glassEffect(.regular.tint(Theme.vividGreen), in: .rect(cornerRadius: Theme.badgeRadius))
            }
        }
    }

    // MARK: - Table

    private func tableSection(_ table: GrammarTable) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            sectionHeader("Reference Table", icon: "tablecells.fill", tint: Theme.brightPurple)

            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                // Header row
                HStack {
                    ForEach(table.headers, id: \.self) { header in
                        Text(header)
                            .font(.nunito(12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, Theme.spacingSM)

                Divider()

                // Data rows
                ForEach(Array(table.rows.enumerated()), id: \.offset) { _, row in
                    HStack {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                            Text(cell)
                                .font(.bodySmall)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, Theme.spacingSM)
                    .padding(.vertical, 4)
                }
            }
            .glassCard(tint: Theme.brightPurple)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String, icon: String, tint: Color) -> some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(title)
                .font(.headingSmall)
        }
    }
}

#Preview {
    NavigationStack {
        GrammarDetailView(rule: GrammarRule(
            id: "preview",
            phaseId: 1,
            title: "Present Tense with b-",
            tag: "Verbs",
            explanation: "In Lebanese Arabic, the present continuous tense is formed by adding the prefix b- to the verb stem. This is distinct from MSA which uses different markers.",
            examples: [
                GrammarExample(arabic: "بحكي عربي", transliteration: "bahki arabi", english: "I speak Arabic", breakdown: "b- prefix indicates present tense"),
            ],
            table: GrammarTable(
                headers: ["Pronoun", "Arabic", "Example"],
                rows: [
                    ["I", "ب-", "بحكي"],
                    ["You (m)", "بت-", "بتحكي"],
                    ["You (f)", "بت-", "بتحكي"],
                ]
            )
        ))
    }
}
