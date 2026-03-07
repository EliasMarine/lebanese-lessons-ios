import Foundation
import AVFoundation

// MARK: - Audio Service

@Observable
final class AudioService: @unchecked Sendable {

    static let shared = AudioService()

    private var audioPlayer: AVAudioPlayer?
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

    // MARK: - TTS (ElevenLabs with System Fallback)

    /// Speak Arabic text using ElevenLabs, falling back to system voice.
    func speak(_ text: String) async {
        isPlaying = true
        defer { isPlaying = false }

        do {
            let audioData = try await ElevenLabsService.shared.speak(text)
            await playAudioData(audioData)
        } catch {
            print("[AudioService] ElevenLabs TTS failed, using system voice: \(error.localizedDescription)")
            speakWithSystemVoice(text: text)
        }
    }

    /// Fallback: use iOS built-in AVSpeechSynthesizer for Arabic TTS.
    private func speakWithSystemVoice(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ar-001")
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

            while audioPlayer?.isPlaying == true {
                try? await Task.sleep(for: .milliseconds(100))
            }
        } catch {
            print("[AudioService] Failed to play audio data: \(error.localizedDescription)")
        }
    }

    // MARK: - Local Sound Effects

    /// Play a local sound effect by name.
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

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
}
