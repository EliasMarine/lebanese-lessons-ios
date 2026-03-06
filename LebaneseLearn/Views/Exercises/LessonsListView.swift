import SwiftUI

// MARK: - Lessons List View

/// Phase/Lesson browser with collapsible phase sections and lesson cards.
struct LessonsListView: View {

    @Environment(\.colorScheme) private var colorScheme

    @State private var phases: [Phase] = []
    @State private var expandedPhases: Set<Int> = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedLesson: Lesson?

    private let lessonService = LessonService.shared

    // MARK: - Body

    var body: some View {
        ScrollView {
            if isLoading {
                loadingView
            } else if let errorMessage {
                errorView(errorMessage)
            } else if phases.isEmpty {
                emptyView
            } else {
                phaseSections
            }
        }
        .background(Theme.bgMainAdaptive(for: colorScheme))
        .navigationTitle("Lessons")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadPhases()
        }
        .refreshable {
            await loadPhases()
        }
        .navigationDestination(item: $selectedLesson) { lesson in
            ExerciseSessionView(lesson: lesson)
        }
    }

    // MARK: - Phase Sections

    private var phaseSections: some View {
        LazyVStack(spacing: Theme.spacingMD) {
            ForEach(Array(phases.enumerated()), id: \.element.id) { index, phase in
                phaseSection(phase, index: index)
                    .fadeUpAnimation(delay: Double(index) * 0.05)
            }
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, Theme.spacingSM)
    }

    // MARK: - Phase Section

    private func phaseSection(_ phase: Phase, index: Int) -> some View {
        VStack(spacing: 0) {
            // Collapsible header
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    if expandedPhases.contains(phase.id) {
                        expandedPhases.remove(phase.id)
                    } else {
                        expandedPhases.insert(phase.id)
                    }
                }
            } label: {
                phaseHeader(phase, index: index)
            }
            .buttonStyle(.plain)

            // Expanded lesson list
            if expandedPhases.contains(phase.id) {
                if let lessons = phase.lessons, !lessons.isEmpty {
                    VStack(spacing: Theme.spacingSM) {
                        ForEach(lessons) { lesson in
                            lessonCard(lesson)
                        }
                    }
                    .padding(.top, Theme.spacingSM)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity
                        )
                    )
                } else {
                    Text("No lessons available yet")
                        .font(.bodyMedium)
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.spacingMD)
                        .transition(.opacity)
                }
            }
        }
    }

    // MARK: - Phase Header

    private func phaseHeader(_ phase: Phase, index: Int) -> some View {
        HStack(spacing: 12) {
            // Progress ring
            ProgressRing(
                progress: phase.progress ?? 0,
                color: phaseColor(for: index),
                lineWidth: 3,
                size: 44
            ) {
                Text("\(index + 1)")
                    .font(.nunito(16, weight: .bold))
                    .foregroundStyle(phaseColor(for: index))
            }

            // Phase info
            VStack(alignment: .leading, spacing: 2) {
                Text(phase.name)
                    .font(.headingSmall)
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))
                    .lineLimit(1)

                Text(phase.subtitle)
                    .font(.bodySmall)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
                    .lineLimit(1)
            }

            Spacer()

            // Expand/collapse chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
                .rotationEffect(expandedPhases.contains(phase.id) ? .degrees(90) : .degrees(0))
                .animation(.spring(response: 0.3), value: expandedPhases.contains(phase.id))
        }
        .padding(Theme.spacingMD)
        .cardStyle()
    }

    // MARK: - Lesson Card

    private func lessonCard(_ lesson: Lesson) -> some View {
        Button {
            selectedLesson = lesson
        } label: {
            HStack(spacing: 12) {
                // Status indicator
                lessonStatusIcon(lesson)

                // Lesson info
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.nunito(15, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary(for: colorScheme))
                        .lineLimit(1)

                    Text(lesson.description)
                        .font(.bodySmall)
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                        .lineLimit(2)
                }

                Spacer()

                // Progress or chevron
                if let progress = lesson.progress {
                    if progress.completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.success)
                    } else if progress.attempts > 0 {
                        ProgressRing(
                            progress: Double(progress.bestScore ?? 0) / 100.0,
                            color: Theme.info,
                            lineWidth: 3,
                            size: 28,
                            showLabel: false
                        )
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary(for: colorScheme))
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary(for: colorScheme))
                }
            }
            .padding(Theme.spacingMD)
            .background(Theme.bgSurfaceAdaptive(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius - 4, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius - 4, style: .continuous)
                    .strokeBorder(Theme.border(for: colorScheme), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func lessonStatusIcon(_ lesson: Lesson) -> some View {
        ZStack {
            Circle()
                .fill(lessonStatusColor(lesson).opacity(0.15))
                .frame(width: 36, height: 36)

            Image(systemName: lessonStatusSFSymbol(lesson))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(lessonStatusColor(lesson))
        }
    }

    private func lessonStatusColor(_ lesson: Lesson) -> Color {
        guard let progress = lesson.progress else { return Theme.info }
        if progress.completed { return Theme.success }
        if progress.attempts > 0 { return Theme.warning }
        return Theme.info
    }

    private func lessonStatusSFSymbol(_ lesson: Lesson) -> String {
        guard let progress = lesson.progress else { return "book.fill" }
        if progress.completed { return "checkmark" }
        if progress.attempts > 0 { return "arrow.clockwise" }
        return "book.fill"
    }

    // MARK: - Loading / Error / Empty

    private var loadingView: some View {
        VStack(spacing: Theme.spacingMD) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Theme.cardRadius)
                    .fill(Theme.bgCardAdaptive(for: colorScheme))
                    .frame(height: 80)
                    .shimmer()
            }
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.top, Theme.spacingMD)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.warning)

            Text("Failed to load lessons")
                .font(.headingSmall)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            Text(message)
                .font(.bodySmall)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await loadPhases() }
            }
            .font(.nunito(14, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Theme.brand)
            .clipShape(Capsule())
        }
        .padding(Theme.spacingXL)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "books.vertical")
                .font(.system(size: 44))
                .foregroundStyle(Theme.textSecondary(for: colorScheme).opacity(0.4))

            Text("No lessons available")
                .font(.headingSmall)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            Text("Check back soon for new content!")
                .font(.bodyMedium)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
        .padding(Theme.spacingXL)
    }

    // MARK: - Data

    private func loadPhases() async {
        isLoading = true
        errorMessage = nil

        do {
            phases = try await lessonService.fetchPhases()
            // Auto-expand the first phase
            if let first = phases.first {
                expandedPhases.insert(first.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Helpers

    private func phaseColor(for index: Int) -> Color {
        let colors: [Color] = [
            Theme.brand, Theme.success, Theme.info,
            Theme.warning, Theme.xpPurple, Theme.brand
        ]
        return colors[index % colors.count]
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LessonsListView()
    }
}
