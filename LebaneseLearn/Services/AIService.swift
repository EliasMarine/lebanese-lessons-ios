import Foundation

actor AIService {
    static let shared = AIService()

    private static let keychainKey = "com.lebaneselearn.ai.apiKey"
    private let baseURL = "https://api.anthropic.com/v1/messages"

    struct Message: Codable, Sendable {
        let role: String
        let content: String
    }

    nonisolated func setAPIKey(_ key: String) {
        KeychainHelper.save(key: Self.keychainKey, value: key)
    }

    nonisolated private func apiKey() -> String? {
        KeychainHelper.load(key: Self.keychainKey)
    }

    func ask(
        prompt: String,
        systemPrompt: String = "You are a Lebanese Arabic language tutor. Respond helpfully with examples in Arabic script, transliteration, and English. Keep responses concise."
    ) async throws -> String {
        try await send(messages: [Message(role: "user", content: prompt)], system: systemPrompt)
    }

    func chat(
        messages: [Message],
        systemPrompt: String = "You are a Lebanese Arabic conversation partner. Speak naturally in Lebanese dialect. Provide transliteration and English translation after each Arabic response. Gently correct mistakes."
    ) async throws -> String {
        try await send(messages: messages, system: systemPrompt)
    }

    private func send(messages: [Message], system: String) async throws -> String {
        guard let key = apiKey() else {
            throw AIError.missingAPIKey
        }

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1024,
            "system": system,
            "messages": messages.map { ["role": $0.role, "content": $0.content] },
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIError.apiError
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let content = json?["content"] as? [[String: Any]]
        let text = content?.first?["text"] as? String

        return text ?? ""
    }

    enum AIError: Error, LocalizedError {
        case missingAPIKey
        case apiError

        var errorDescription: String? {
            switch self {
            case .missingAPIKey: "AI API key not configured"
            case .apiError: "AI API request failed"
            }
        }
    }
}
