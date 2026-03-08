# Lebanese Learn

A native iOS app for learning Lebanese Arabic (Levantine dialect), built with SwiftUI and designed with a bold, playful Duolingo-inspired aesthetic.

## Features

- **6-Phase Curriculum** — Structured learning path from basic greetings to advanced conversation, with vocab, dialogues, grammar, culture notes, and exercises per phase
- **Interactive Exercises** — Multiple choice, fill-in-the-blank, and matching exercises with instant feedback, star ratings, and XP rewards
- **Spaced Repetition (SRS)** — Flashcard review system with SM-2 algorithm for long-term vocabulary retention
- **AI Tutor** — Conversational AI chat powered by Claude for practicing Lebanese Arabic in context
- **Text-to-Speech** — Native Arabic pronunciation via ElevenLabs API integration
- **Gamification** — XP system, streaks, confetti celebrations, star ratings, and leaderboard
- **Offline-First** — All lesson content bundled locally as JSON; no server required to learn

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI (iOS 26+) |
| Data | SwiftData |
| Cloud | CloudKit (leaderboard sync) |
| AI | Claude API (AI tutor) |
| TTS | ElevenLabs API |
| Fonts | Nunito (with system rounded fallback) |
| Build | XcodeGen (`project.yml`) |
| Language | Swift 6.0 (strict concurrency) |

## Project Structure

```
LebaneseLearn/
├── App/                    # App entry point, ContentView, entitlements
├── Theme/                  # Design system (colors, fonts, modifiers), MosaicLogo
├── Extensions/             # View modifiers (animations, shimmer, speakable)
├── Models/
│   ├── Content/            # Codable models for JSON content (Phase, VocabItem, etc.)
│   └── UserData/           # SwiftData @Model classes (UserProfile, SRSCardRecord, etc.)
├── Services/               # Business logic (ContentManager, SRSEngine, XPEngine, AI, Audio, CloudKit)
├── Views/
│   ├── Dashboard/          # MainTabView, DashboardView
│   ├── Exercises/          # LessonsListView, PhaseDetailView, ExerciseSessionView, etc.
│   ├── Review/             # ReviewDashboardView, ReviewSessionView (SRS flashcards)
│   ├── AI/                 # AIChatView (AI tutor)
│   ├── Leaderboard/        # LeaderboardView, PodiumView
│   ├── Profile/            # ProfileView (settings, API keys, study goals)
│   ├── Onboarding/         # OnboardingView (4-page setup flow)
│   └── Components/         # Reusable: StatCard, ProgressRing, XPPopup, ConfettiView, StarRatingView
└── Resources/
    └── Content/            # Bundled JSON curriculum (phases, vocab, dialogues, grammar, etc.)
```

## Getting Started

### Prerequisites

- Xcode 26+ (with iOS 26 SDK)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — `brew install xcodegen`

### Setup

```bash
# Clone the repo
git clone https://github.com/your-org/lebanese-lessons-ios.git
cd lebanese-lessons-ios

# Generate the Xcode project
xcodegen generate

# Open in Xcode
open LebaneseLearn.xcodeproj
```

### Optional API Keys

The app works offline for all lesson content. For AI tutor and TTS features, add your API keys in **Profile > API Settings**:

- **AI API Key** — [Anthropic Claude API](https://console.anthropic.com/)
- **ElevenLabs API Key** + **Voice ID** — [ElevenLabs](https://elevenlabs.io/)

## Design System

The app uses a bold, playful design language inspired by Duolingo:

- **Colors** — Bright greens, warm oranges, sky blues, coral reds, sunny yellows
- **Cards** — Solid white backgrounds with colored borders and chunky bottom shadows
- **Buttons** — Capsule-shaped with color-matched shadows and bouncy press animations
- **Gamification** — XP popups, confetti bursts, star ratings, streak flames
- **Typography** — Nunito font family throughout

## License

All rights reserved.
