import SwiftUI

// MARK: - Dialogue View

struct DialogueView: View {
    let dialogue: Dialogue

    @State private var currentLineIndex = 0
    @State private var showAllLines = false
    @State private var showTranslation: Set<Int> = []

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Header
                header
                    .fadeUpAnimation()

                // Controls
                controls
                    .fadeUpAnimation(delay: 0.1)

                // Dialogue lines
                VStack(spacing: Theme.spacingMD) {
                    let linesToShow = showAllLines ? dialogue.lines : Array(dialogue.lines.prefix(currentLineIndex + 1))

                    ForEach(Array(linesToShow.enumerated()), id: \.offset) { index, line in
                        dialogueLine(line, index: index)
                            .fadeUpAnimation(delay: showAllLines ? 0 : 0.15)
                    }
                }
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingSM)
        }
        .navigationTitle(dialogue.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: Theme.spacingSM) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.hotPink)

            Text(dialogue.title)
                .font(.headingMedium)

            if let context = dialogue.context {
                Text(context)
                    .font(.bodyMedium)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Text("\(dialogue.lines.count) lines")
                .font(.bodySmall)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .glassCard(tint: Theme.hotPink)
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: Theme.spacingMD) {
            Button {
                withAnimation {
                    showAllLines.toggle()
                    if showAllLines { currentLineIndex = dialogue.lines.count - 1 }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: showAllLines ? "eye.slash" : "eye")
                    Text(showAllLines ? "Step Through" : "Show All")
                        .font(.bodySmall)
                }
                .foregroundStyle(.primary)
            }
            .glassButton()

            if !showAllLines {
                Button {
                    withAnimation(.easeOut(duration: 0.3)) {
                        if currentLineIndex < dialogue.lines.count - 1 {
                            currentLineIndex += 1
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down")
                        Text("Next Line")
                            .font(.bodySmall)
                    }
                    .foregroundStyle(.primary)
                }
                .glassButton()
                .disabled(currentLineIndex >= dialogue.lines.count - 1)
                .opacity(currentLineIndex >= dialogue.lines.count - 1 ? 0.5 : 1)
            }
        }
    }

    // MARK: - Dialogue Line

    private func dialogueLine(_ line: DialogueLine, index: Int) -> some View {
        let isEven = index % 2 == 0

        return HStack {
            if !isEven { Spacer() }

            VStack(alignment: isEven ? .leading : .trailing, spacing: Theme.spacingSM) {
                // Speaker
                HStack(spacing: 6) {
                    if isEven {
                        speakerAvatar(name: line.speaker, color: Theme.electricBlue)
                    }
                    VStack(alignment: isEven ? .leading : .trailing, spacing: 0) {
                        Text(line.speaker)
                            .font(.nunito(13, weight: .bold))
                            .foregroundStyle(isEven ? Theme.electricBlue : Theme.hotPink)
                        Text(line.speakerRole)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if !isEven {
                        speakerAvatar(name: line.speaker, color: Theme.hotPink)
                    }
                }

                // Arabic text
                Text(line.arabic)
                    .font(.nunito(20, weight: .bold))
                    .foregroundStyle(.primary)
                    .speakable(line.arabic)
                    .multilineTextAlignment(isEven ? .leading : .trailing)

                // Transliteration
                Text(line.transliteration)
                    .font(.nunito(14, weight: .medium))
                    .foregroundStyle(Theme.brightPurple)
                    .italic()

                // Toggle translation
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if showTranslation.contains(index) {
                            showTranslation.remove(index)
                        } else {
                            showTranslation.insert(index)
                        }
                    }
                } label: {
                    if showTranslation.contains(index) {
                        Text(line.english)
                            .font(.bodySmall)
                            .foregroundStyle(.secondary)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "eye")
                                .font(.caption)
                            Text("Show translation")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(Theme.spacingMD)
            .glassEffect(
                .regular.tint(isEven ? Theme.electricBlue : Theme.hotPink),
                in: .rect(cornerRadius: Theme.cardRadius)
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: isEven ? .leading : .trailing)

            if isEven { Spacer() }
        }
    }

    // MARK: - Speaker Avatar

    private func speakerAvatar(name: String, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 28, height: 28)
            Text(String(name.prefix(1)).uppercased())
                .font(.nunito(12, weight: .bold))
                .foregroundStyle(color)
        }
    }
}

#Preview {
    NavigationStack {
        DialogueView(dialogue: Dialogue(
            id: "preview",
            phaseId: 1,
            title: "At the Coffee Shop",
            context: "Two friends meeting for coffee",
            lines: [
                DialogueLine(speaker: "Ahmad", speakerRole: "friend", arabic: "مرحبا، كيفك؟", transliteration: "marhaba, kifak?", english: "Hello, how are you?", audioFile: nil),
                DialogueLine(speaker: "Maya", speakerRole: "friend", arabic: "الحمدلله، منيحة", transliteration: "il-hamdilla, mniiha", english: "Good, thank God", audioFile: nil),
            ]
        ))
    }
}
