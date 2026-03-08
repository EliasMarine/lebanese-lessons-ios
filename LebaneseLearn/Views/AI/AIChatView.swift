import SwiftUI
import SwiftData

struct AIChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var conversationRecord: AIConversationRecord?

    struct ChatMessage: Identifiable, Codable {
        let id: UUID
        let role: String
        let content: String
        let timestamp: Date

        init(role: String, content: String) {
            self.id = UUID()
            self.role = role
            self.content = content
            self.timestamp = .now
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Message list
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(spacing: Theme.spacingSM) {
                        if messages.isEmpty {
                            welcomeCard
                                .padding(.top, Theme.spacingXL)
                        }

                        ForEach(messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }

                        if isLoading {
                            loadingIndicator
                        }
                    }
                    .padding(.horizontal, Theme.spacingMD)
                    .padding(.vertical, Theme.spacingSM)
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Error message
            if let errorMessage {
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Theme.sunsetOrange)
                    Text(errorMessage)
                        .font(.bodySmall)
                        .foregroundStyle(Theme.sunsetOrange)
                }
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)
            }

            // Input area
            inputBar
        }
        .navigationTitle("AI Tutor")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Welcome Card

    private var welcomeCard: some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.electricBlue)

            Text("Lebanese Arabic Tutor")
                .font(.headingMedium)

            Text("Practice conversation, ask questions about grammar, or request translations. I'll help you learn!")
                .font(.bodyMedium)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // Suggested prompts
            VStack(spacing: Theme.spacingSM) {
                suggestionButton("How do I say 'thank you' in Lebanese?")
                suggestionButton("Teach me common greetings")
                suggestionButton("What's the difference between Lebanese and MSA?")
            }
        }
        .glassCard(tint: Theme.electricBlue)
    }

    private func suggestionButton(_ text: String) -> some View {
        Button {
            inputText = text
            sendMessage()
        } label: {
            Text(text)
                .font(.bodySmall)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.spacingSM)
                .padding(.vertical, Theme.spacingXS)
        }
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: Theme.badgeRadius))
    }

    // MARK: - Message Bubble

    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.role == "user" {
                Spacer()
            }

            VStack(alignment: message.role == "user" ? .trailing : .leading, spacing: Theme.spacingXS) {
                Text(message.content)
                    .font(.bodyMedium)
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)

                // Make Arabic text in AI responses speakable
                if message.role == "assistant" {
                    let arabicParts = extractArabic(from: message.content)
                    if !arabicParts.isEmpty {
                        ForEach(arabicParts, id: \.self) { arabic in
                            HStack(spacing: 4) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.caption)
                                    .foregroundStyle(Theme.electricBlue)
                                Text(arabic)
                                    .font(.nunito(14, weight: .semibold))
                                    .foregroundStyle(Theme.electricBlue)
                            }
                            .speakable(arabic)
                        }
                    }
                }
            }
            .padding(Theme.spacingMD)
            .glassEffect(
                message.role == "user"
                    ? .regular.tint(Theme.brand)
                    : .regular.tint(Theme.electricBlue),
                in: .rect(cornerRadius: Theme.cardRadius)
            )
            .frame(maxWidth: 300, alignment: message.role == "user" ? .trailing : .leading)

            if message.role == "assistant" {
                Spacer()
            }
        }
    }

    // MARK: - Loading Indicator

    private var loadingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Theme.electricBlue)
                        .frame(width: 8, height: 8)
                        .opacity(0.4)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(i) * 0.2),
                            value: isLoading
                        )
                }
            }
            .padding(Theme.spacingMD)
            .glassEffect(.regular.tint(Theme.electricBlue), in: .rect(cornerRadius: Theme.cardRadius))

            Spacer()
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: Theme.spacingSM) {
            TextField("Ask anything in Lebanese Arabic...", text: $inputText, axis: .vertical)
                .font(.bodyMedium)
                .lineLimit(1...4)
                .padding(Theme.spacingSM)
                .glassEffect(in: .rect(cornerRadius: Theme.inputRadius))
                .onSubmit {
                    sendMessage()
                }

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        inputText.trimmingCharacters(in: .whitespaces).isEmpty
                            ? .secondary
                            : Theme.brand
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, Theme.spacingSM)
        .glassEffect(in: .rect(cornerRadius: 0))
    }

    // MARK: - Actions

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        let userMessage = ChatMessage(role: "user", content: text)
        messages.append(userMessage)
        inputText = ""
        errorMessage = nil
        isLoading = true

        Task {
            do {
                let aiMessages = messages.map { AIService.Message(role: $0.role, content: $0.content) }
                let response = try await AIService.shared.chat(messages: aiMessages)

                let assistantMessage = ChatMessage(role: "assistant", content: response)
                messages.append(assistantMessage)

                saveConversation()
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    private func saveConversation() {
        let jsonData = try? JSONEncoder().encode(messages)
        let jsonString = jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"

        if let record = conversationRecord {
            record.messagesJSON = jsonString
            record.updatedAt = .now
        } else {
            let record = AIConversationRecord(
                phaseId: 0,
                title: messages.first?.content.prefix(50).description ?? "Chat",
                messagesJSON: jsonString
            )
            modelContext.insert(record)
            conversationRecord = record
        }

        try? modelContext.save()
    }

    // MARK: - Helpers

    private func extractArabic(from text: String) -> [String] {
        let arabicRange = UnicodeScalar("؀").value...UnicodeScalar("ۿ").value
        var results: [String] = []
        var currentArabic = ""

        for char in text {
            let scalars = char.unicodeScalars
            if scalars.allSatisfy({ arabicRange.contains($0.value) || $0 == " " }) && char != " " {
                currentArabic.append(char)
            } else {
                if !currentArabic.isEmpty {
                    let trimmed = currentArabic.trimmingCharacters(in: .whitespaces)
                    if trimmed.count >= 2 {
                        results.append(trimmed)
                    }
                    currentArabic = ""
                }
            }
        }

        if !currentArabic.isEmpty {
            let trimmed = currentArabic.trimmingCharacters(in: .whitespaces)
            if trimmed.count >= 2 {
                results.append(trimmed)
            }
        }

        return results
    }
}

#Preview {
    NavigationStack {
        AIChatView()
    }
    .modelContainer(for: [AIConversationRecord.self, UserProfile.self], inMemory: true)
}
