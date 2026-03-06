import Foundation
import AVFoundation
import SwiftUI

// MARK: - Audio Service

@Observable
final class AudioService: @unchecked Sendable {

    static let shared = AudioService()

    private var audioPlayer: AVAudioPlayer?
    private var urlPlayer: AVPlayer?

    private(set) var isPlaying = false

    private init() {
        configureAudioSession()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("[AudioService] Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    // MARK: - TTS (Text-to-Speech via API)

    /// Request TTS audio from the backend and play it.
    /// The backend uses Google Cloud TTS (ar-XA-Wavenet-B) with browser Speech Synthesis fallback.
    func speak(text: String) async {
        isPlaying = true
        defer { isPlaying = false }

        do {
            let api = APIService.shared
            let body = TTSRequest(text: text)
            let response: TTSResponse = try await api.post("/api/tts", body: body)

            guard let audioData = Data(base64Encoded: response.audio) else {
                print("[AudioService] Failed to decode base64 audio data")
                return
            }

            await playAudioData(audioData)
        } catch {
            print("[AudioService] TTS request failed: \(error.localizedDescription)")
            // Fall back to iOS built-in speech synthesis
            speakWithSystemVoice(text: text)
        }
    }

    /// Fallback: use iOS built-in AVSpeechSynthesizer for Arabic TTS.
    private func speakWithSystemVoice(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ar-001") // Modern Standard Arabic
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        utterance.pitchMultiplier = 1.0

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }

    // MARK: - Play Audio Data

    @MainActor
    private func playAudioData(_ data: Data) async {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

            // Wait for playback to finish
            while audioPlayer?.isPlaying == true {
                try? await Task.sleep(for: .milliseconds(100))
            }
        } catch {
            print("[AudioService] Failed to play audio data: \(error.localizedDescription)")
        }
    }

    // MARK: - Play Audio from URL

    /// Play audio from a remote URL (e.g., pre-recorded pronunciation clips).
    func playAudio(from url: URL) async {
        isPlaying = true
        defer { isPlaying = false }

        let playerItem = AVPlayerItem(url: url)
        urlPlayer = AVPlayer(playerItem: playerItem)
        urlPlayer?.play()

        // Wait for playback to complete
        await withCheckedContinuation { continuation in
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: playerItem,
                queue: .main
            ) { _ in
                continuation.resume()
            }
        }
    }

    // MARK: - Local Sound Effects

    /// Play a local sound effect by name (e.g., "correct", "wrong", "level-up").
    /// Sound files should be added to the app bundle as .mp3 or .wav.
    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3")
                ?? Bundle.main.url(forResource: name, withExtension: "wav")
                ?? Bundle.main.url(forResource: name, withExtension: "aiff")
        else {
            print("[AudioService] Sound file not found: \(name)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("[AudioService] Failed to play sound '\(name)': \(error.localizedDescription)")
        }
    }

    // MARK: - Stop

    /// Stop any currently playing audio.
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        urlPlayer?.pause()
        urlPlayer = nil
        isPlaying = false
    }
}

// MARK: - TTS Request / Response

private struct TTSRequest: Codable, Sendable {
    let text: String
}

private struct TTSResponse: Codable, Sendable {
    let audio: String // base64-encoded audio data
}
