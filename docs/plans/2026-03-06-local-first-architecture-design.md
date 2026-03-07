# Local-First Architecture Design

**Date:** 2026-03-06
**Status:** Approved

## Goal

Convert the Lebanese Learn iOS app from a server-dependent architecture (arabicisbeautiful.com API) to a local-first app where all core learning runs on-device. External calls are limited to ElevenLabs TTS, AI API (Claude/OpenAI), and CloudKit leaderboards.

## Architecture: Static JSON + SwiftData for User Data

**Static Content Layer** — Bundled JSON files decoded into `Codable` structs on-demand. Content is read-only and ships with the app binary.

**User Data Layer** — SwiftData `@Model` classes for mutable user state (progress, SRS, XP, badges, etc.).

**Rationale:** Standard iOS practice for educational/content apps. Static content doesn't benefit from a database. Simpler, fewer migrations, faster to build.

---

## Data Architecture

### Static Content (Bundled JSON)

Source: TypeScript content from `/lebanese-lessons/src/content/` converted to JSON.

```
Resources/Content/
  phases.json
  vocab/phase1.json ... phase6.json
  exercises/phase1.json ... phase6.json
  dialogues/phase1.json ... phase6.json
  grammar/phase1.json ... phase6.json
  shadowing/phase1.json ... phase3.json
  scenarios/phase2.json ... phase4.json
  verbs/phase1.json ... phase3.json
  culture/phase1.json ... phase6.json
  reading.json
  proverbs.json
  roots.json
  minimal-pairs.json
  msa-comparison.json
  sounds.json
  placement-test.json
  journal.json
```

Swift `Codable` structs mirror the TypeScript types from `types.ts`:
- `Phase`, `VocabItem`, `ExerciseSet`, `QuizQuestion`, `FillBlankQuestion`, `MatchingPair`
- `Dialogue`, `DialogueLine`, `GrammarRule`, `SoundItem`, `LetterForm`
- `ShadowingItem`, `ProverbItem`, `CultureNote`, `ReadingPassage`
- `ScenarioLesson`, `ScenarioBranch`, `ScenarioChoice`
- `VerbConjugation`, `MSAComparison`, `JournalPrompt`
- `MinimalPairSet`, `ArabicRoot`, `PlacementQuestion`

`ContentManager` class loads and caches JSON by phase on-demand.

### User Data (SwiftData @Model)

- `UserProfile` — name, totalXP, level, levelTitle, streak, studyGoalMinutes, timezone, hasCompletedOnboarding
- `LessonProgress` — phaseId, lessonSlug, completed, bestScore, attempts, lastAttemptDate
- `SRSCard` — vocabItemId, phaseId, easeFactor, interval, repetitions, nextReviewAt, lastReviewedAt, createdAt
- `SRSReviewLog` — cardId, rating, easeFactor, interval, reviewedAt
- `ExerciseResult` — phaseId, exerciseId, exerciseType, score, totalQuestions, correctAnswers, timeSpent, completedAt
- `EarnedBadge` — badgeId, earnedAt
- `XPEntry` — amount, source, sourceId, earnedAt
- `DailyActivity` — date, minutesStudied, cardsReviewed, exercisesCompleted
- `CompletedItem` — phaseId, tab, itemId, completedAt
- `AIConversation` — phaseId, title, messages (JSON string), createdAt, updatedAt

### CloudKit (Leaderboard)

- `CKRecord` type: `LeaderboardEntry`
- Fields: userName, totalXP, level, levelTitle, levelProgress
- Database: `CKContainer.default().publicCloudDatabase`
- Read: fetch top entries sorted by totalXP descending
- Write: upsert current user's record when XP changes
- No private database needed — leaderboard is inherently public

---

## External Services

### ElevenLabs TTS

- `ElevenLabsService` — async actor
- Endpoint: `POST https://api.elevenlabs.io/v1/text-to-speech/{voice_id}`
- API key stored in Keychain
- Audio response cached locally (file-based cache keyed by text hash) to avoid repeat calls
- Fallback: `AVSpeechSynthesizer` with Arabic locale when offline or API fails
- Trigger: tap any Arabic text throughout the app

### AI API (Claude/OpenAI)

- `AIService` — async actor
- Features:
  - Conversation practice — multi-turn Lebanese Arabic chat
  - Grammar explanations — contextual help on rules and mistakes
  - Exercise feedback — personalized tips after exercise completion
  - Translation help — free-form queries
- API key stored in Keychain
- Conversation history persisted in SwiftData (`AIConversation`)

---

## UI & Design

### Liquid Glass (iOS 26)

- Deployment target: iOS 26
- Tab bar: `TabView` with `.glassEffect()`
- Cards/panels: `.glassEffect(in: .rect(cornerRadius: 16))`
- Buttons: `.buttonStyle(.glass)` / `.buttonStyle(.glassProminent)`
- Grouped elements: `GlassEffectContainer`
- Brand accent: coral `#E94560` as `.tint()` within glass elements

### Tab Structure

1. **Home** — dashboard, streaks, daily challenges, activity feed
2. **Lessons** — phase list -> content tabs (vocab, exercises, dialogues, grammar, etc.)
3. **Review** — SRS flashcard sessions
4. **Leaderboard** — CloudKit rankings
5. **Profile** — settings, stats, study goals

### No Auth

Single-user local app. First launch: onboarding (name, study goal, optional placement test) then straight to Home.

---

## App Structure

```
LebaneseLearn/
├── App/
│   ├── LebaneseLearnApp.swift
│   └── ContentView.swift
├── Models/
│   ├── Content/           — Codable structs (read-only)
│   └── UserData/          — SwiftData @Model classes (mutable)
├── Services/
│   ├── ContentManager.swift
│   ├── ElevenLabsService.swift
│   ├── AIService.swift
│   ├── CloudKitService.swift
│   ├── AudioService.swift
│   ├── SRSEngine.swift
│   └── XPEngine.swift
├── Views/
│   ├── Onboarding/
│   ├── Dashboard/
│   ├── Lessons/
│   ├── Exercises/
│   ├── Review/
│   ├── Leaderboard/
│   ├── Profile/
│   ├── AI/
│   └── Components/
├── Resources/
│   └── Content/           — Bundled JSON files
├── Extensions/
└── Theme/
    └── Theme.swift
```

---

## Git & Versioning

**SemVer:** `MAJOR.MINOR.PATCH`
- `1.0.0` — Initial release
- `1.1.0` — New feature
- `1.1.1` — Bug fix
- `2.0.0` — Breaking change / data migration

**Branches:**
- `main` — shippable, tagged releases
- `dev` — integration branch
- `feature/short-description` — feature work
- `fix/short-description` — bug fixes
- `release/1.x.0` — release prep

**Commits:** Conventional Commits
- `feat:`, `fix:`, `refactor:`, `content:`, `chore:`

**Tags:** `v1.0.0` on `main` after release merge.

**PRs:** feature -> `dev` via PR. `dev` -> `main` via release PR with changelog.

---

## Content Types Summary

| Content Type | Files | Phases | Description |
|---|---|---|---|
| Phases | 1 | — | 6 phase definitions with metadata |
| Vocabulary | 6 | 1-6 | Arabic words with transliteration, examples |
| Exercises | 6 | 1-6 | Multiple choice, fill-blank, matching, sentence builder, dictation |
| Dialogues | 6 | 1-6 | Conversational exchanges with speaker roles |
| Grammar | 6 | 1-6 | Rules with explanations, examples, tables |
| Shadowing | 3 | 1-3 | Listen-and-repeat exercises |
| Scenarios | 3 | 2-4 | Branching interactive dialogues |
| Verbs | 3 | 1-3 | Full conjugation tables |
| Culture | 6 | 1-6 | Cultural notes and context |
| Reading | 1 | mixed | Passages with comprehension questions |
| Proverbs | 1 | 3-6 | Lebanese proverbs with meanings |
| Roots | 1 | — | Arabic root system with derived words |
| Minimal Pairs | 1 | — | Sound discrimination training |
| MSA Comparison | 1 | — | MSA vs Lebanese differences |
| Sounds | 1 | 1 | Arabic alphabet with pronunciation |
| Placement Test | 1 | 1-5 | 15-question diagnostic |
| Journal | 1 | 3 | Writing prompts |
