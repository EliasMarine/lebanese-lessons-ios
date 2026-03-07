import SwiftUI

struct LessonsListView: View {
    private let phases = ContentManager.shared.phases()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.spacingMD) {
                ForEach(Array(phases.enumerated()), id: \.element.id) { index, phase in
                    NavigationLink(value: phase) {
                        phaseCard(phase)
                    }
                    .buttonStyle(.plain)
                    .fadeUpAnimation(delay: Double(index) * 0.05)
                }
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingSM)
        }
        .navigationTitle("Lessons")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Phase.self) { phase in
            PhaseDetailView(phase: phase)
        }
    }

    // MARK: - Phase Card

    private func phaseCard(_ phase: Phase) -> some View {
        HStack(spacing: Theme.spacingMD) {
            // Gradient accent strip
            RoundedRectangle(cornerRadius: 4)
                .fill(Theme.phaseGradient(for: phase.id))
                .frame(width: 6)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(phase.title)
                    .font(.headingSmall)
                    .foregroundStyle(.primary)

                Text(phase.titleArabic)
                    .font(.nunito(16, weight: .medium))
                    .foregroundStyle(Theme.electricBlue)

                Text(phase.subtitle)
                    .font(.bodySmall)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 80)
        .glassCard()
    }
}

// MARK: - Phase: Hashable

extension Phase: Hashable {
    static func == (lhs: Phase, rhs: Phase) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    NavigationStack {
        LessonsListView()
    }
}
