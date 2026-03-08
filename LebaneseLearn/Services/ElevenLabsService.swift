import Foundation
import AVFoundation

actor ElevenLabsService {
    static let shared = ElevenLabsService()

    private static let apiKeyKey = "com.lebaneselearn.elevenlabs.apiKey"
    private static let voiceIdKey = "com.lebaneselearn.elevenlabs.voiceId"
    private let cacheDir: URL

    init() {
        let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDir = cache.appendingPathComponent("tts-cache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    nonisolated func setAPIKey(_ key: String) {
        KeychainHelper.save(key: Self.apiKeyKey, value: key)
    }

    nonisolated func setVoiceId(_ voiceId: String) {
        KeychainHelper.save(key: Self.voiceIdKey, value: voiceId)
    }

    nonisolated private func apiKey() -> String? {
        KeychainHelper.load(key: Self.apiKeyKey)
    }

    nonisolated private func voiceId() -> String? {
        KeychainHelper.load(key: Self.voiceIdKey)
    }

    func speak(_ text: String) async throws -> Data {
        let cacheKey = text.data(using: .utf8)!.base64EncodedString()
            .prefix(64)
            .replacingOccurrences(of: "/", with: "_")
        let cacheFile = cacheDir.appendingPathComponent("\(cacheKey).mp3")

        if FileManager.default.fileExists(atPath: cacheFile.path) {
            return try Data(contentsOf: cacheFile)
        }

        guard let key = apiKey(), let voice = voiceId() else {
            throw TTSError.missingCredentials
        }

        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voice)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "xi-api-key")

        let body: [String: String] = [
            "text": text,
            "model_id": "eleven_multilingual_v2",
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TTSError.apiError
        }

        try data.write(to: cacheFile)
        return data
    }

    enum TTSError: Error, LocalizedError {
        case missingCredentials
        case apiError

        var errorDescription: String? {
            switch self {
            case .missingCredentials: "ElevenLabs API key or voice ID not configured"
            case .apiError: "ElevenLabs API request failed"
            }
        }
    }
}
