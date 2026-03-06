import SwiftUI

// MARK: - Skill Tree View

/// A vertical learning path with connected phase nodes.
/// Completed nodes are green with checkmarks, the current node pulses with
/// the brand color, and future nodes are gray/locked.
struct SkillTreeView: View {

    @Environment(\.colorScheme) private var colorScheme

    @State private var phases: [Phase] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedPhase: Phase?

    // Animations
    @State private var pulsing = false
    @State private var sparkleRotation: Double = 0
    @State private var appeared = false

    private let lessonService = LessonService.shared

    // MARK: - Computed

    /// Index of the first phase that is not fully completed.
    private var currentPhaseIndex: Int {
        phases.firstIndex(where: { ($0.progress ?? 0) < 1.0 }) ?? phases.count
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            if isLoading {
                loadingView
            } else if let errorMessage {
                errorView(errorMessage)
            } else {
                skillTreePath
            }
        }
        .background(Theme.bgMainAdaptive(for: colorScheme))
        .navigationTitle("Learning Path")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadPhases()
        }
        .refreshable {
            await loadPhases()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulsing = true
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
        }
        .sheet(item: $selectedPhase) { phase in
            NavigationStack {
                phaseDetailSheet(phase)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Skill Tree Path

    private var skillTreePath: some View {
        VStack(spacing: 0) {
            ForEach(Array(phases.enumerated()), id: \.element.id) { index, phase in
                let status = nodeStatus(for: index)

                // Node
                skillNode(phase: phase, index: index, status: status)
                    .fadeUpAnimation(delay: Double(index) * 0.1)

                // Connector line (except after last node)
                if index < phases.count - 1 {
                    connectorLine(
                        fromStatus: status,
                        toStatus: nodeStatus(for: index + 1)
                    )
                }
            }
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, Theme.spacingLG)
    }

    // MARK: - Skill Node

    private func skillNode(phase: Phase, index: Int, status: NodeStatus) -> some View {
        Button {
            if status != .locked {
                selectedPhase = phase
            }
        } label: {
            HStack(spacing: Theme.spacingMD) {
                Spacer()

                // Node circle
                nodeCircle(phase: phase, index: index, status: status)

                // Phase info
                VStack(alignment: .leading, spacing: 4) {
                    Text(phase.name)
                        .font(.nunito(status == .current ? 18 : 16, weight: .bold))
                        .foregroundStyle(
                            status == .locked
                                ? Theme.textSecondary(for: colorScheme).opacity(0.5)
                                : Theme.textPrimary(for: colorScheme)
                        )
                        .lineLimit(1)

                    Text(phase.subtitle)
                        .font(.bodySmall)
                        .foregroundStyle(
                            status == .locked
                                ? Theme.textSecondary(for: colorScheme).opacity(0.3)
                                : Theme.textSecondary(for: colorScheme)
                        )
                        .lineLimit(1)

                    // Completion percentage
                    if status != .locked {
                        let pct = Int((phase.progress ?? 0) * 100)
                        Text("\(pct)% complete")
                            .font(.nunito(11, weight: .semibold))
                            .foregroundStyle(statusColor(status))
                    }
                }

                Spacer()
            }
            .padding(.vertical, Theme.spacingMD)
            .padding(.horizontal, Theme.spacingSM)
        }
        .buttonStyle(.plain)
        .disabled(status == .locked)
    }

    // MARK: - Node Circle

    private func nodeCircle(phase: Phase, index: Int, status: NodeStatus) -> some View {
        let size: CGFloat = status == .current ? 72 : 56

        return ZStack {
            // Decorative sparkles for completed nodes
            if status == .completed {
                sparklesDecoration(size: size)
            }

            // Outer glow for current node
            if status == .current {
                Circle()
                    .fill(Theme.brand.opacity(0.15))
                    .frame(width: size + 16, height: size + 16)
                    .scaleEffect(pulsing ? 1.1 : 0.95)
            }

            // Main circle
            Circle()
                .fill(nodeGradient(status))
                .frame(width: size, height: size)
                .shadow(
                    color: statusColor(status).opacity(0.3),
                    radius: status == .current ? 12 : 6,
                    x: 0,
                    y: 4
                )

            // Inner content
            Group {
                switch status {
                case .completed:
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.32, weight: .bold))
                        .foregroundStyle(.white)

                case .current:
                    Text("\(index + 1)")
                        .font(.nunito(size * 0.36, weight: .bold))
                        .foregroundStyle(.white)

                case .locked:
                    Image(systemName: "lock.fill")
                        .font(.system(size: size * 0.28, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .frame(width: size + 20, height: size + 20)
    }

    private func sparklesDecoration(size: CGFloat) -> some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Theme.warning.opacity(0.7))
                    .offset(
                        x: cos(Double(i) * .pi / 2 + sparkleRotation * .pi / 180) * (size * 0.55),
                        y: sin(Double(i) * .pi / 2 + sparkleRotation * .pi / 180) * (size * 0.55)
                    )
            }
        }
    }

    // MARK: - Connector Line

    private func connectorLine(fromStatus: NodeStatus, toStatus: NodeStatus) -> some View {
        VStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(connectorColor(from: fromStatus, to: toStatus))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: 36)
    }

    private func connectorColor(from: NodeStatus, to: NodeStatus) -> Color {
        if from == .completed && (to == .completed || to == .current) {
            return Theme.success.opacity(0.5)
        }
        return Theme.textSecondary(for: colorScheme).opacity(0.2)
    }

    // MARK: - Phase Detail Sheet

    private func phaseDetailSheet(_ phase: Phase) -> some View {
        VStack(spacing: Theme.spacingMD) {
            // Header
            let idx = phases.firstIndex(where: { $0.id == phase.id }) ?? 0
            let status = nodeStatus(for: idx)

            nodeCircle(phase: phase, index: idx, status: status)
                .padding(.top, Theme.spacingSM)

            Text(phase.name)
                .font(.headingLarge)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            Text(phase.subtitle)
                .font(.bodyMedium)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))

            Text(phase.description)
                .font(.bodyMedium)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingMD)

            // Progress
            let progress = phase.progress ?? 0
            ProgressRing(
                progress: progress,
                color: statusColor(status),
                lineWidth: 6,
                size: 80
            )

            // Lesson count
            if let lessons = phase.lessons {
                let completed = lessons.filter { $0.progress?.completed == true }.count
                Text("\(completed)/\(lessons.count) lessons completed")
                    .font(.bodySmall)
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.bgMainAdaptive(for: colorScheme))
    }

    // MARK: - Node Status

    private enum NodeStatus {
        case completed
        case current
        case locked
    }

    private func nodeStatus(for index: Int) -> NodeStatus {
        if index < currentPhaseIndex { return .completed }
        if index == currentPhaseIndex { return .current }
        return .locked
    }

    private func statusColor(_ status: NodeStatus) -> Color {
        switch status {
        case .completed: return Theme.success
        case .current:   return Theme.brand
        case .locked:    return Theme.textSecondary(for: colorScheme).opacity(0.3)
        }
    }

    private func nodeGradient(_ status: NodeStatus) -> LinearGradient {
        switch status {
        case .completed:
            return LinearGradient(
                colors: [Theme.success, Theme.success.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .current:
            return LinearGradient(
                colors: [Theme.brand, Theme.brand.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .locked:
            return LinearGradient(
                colors: [
                    Theme.textSecondary(for: colorScheme).opacity(0.25),
                    Theme.textSecondary(for: colorScheme).opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: - Data Loading

    private func loadPhases() async {
        isLoading = true
        errorMessage = nil

        do {
            phases = try await lessonService.fetchPhases()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Loading / Error

    private var loadingView: some View {
        VStack(spacing: Theme.spacingLG) {
            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: 16) {
                    Circle()
                        .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                        .frame(width: 56, height: 56)
                        .shimmer()

                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                            .frame(width: 140, height: 14)
                            .shimmer()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.bgSurfaceAdaptive(for: colorScheme))
                            .frame(width: 100, height: 10)
                            .shimmer()
                    }
                }
            }
        }
        .padding(Theme.spacingXL)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.warning)

            Text("Could not load skill tree")
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
}

// MARK: - Phase: Hashable & Identifiable for sheet

extension Phase: Hashable {
    static func == (lhs: Phase, rhs: Phase) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SkillTreeView()
    }
}
