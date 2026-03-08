# Local-First Architecture Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Convert Lebanese Learn iOS from server-dependent to local-first with SwiftData, bundled JSON content, CloudKit leaderboards, ElevenLabs TTS, and external AI — all styled with iOS 26 Liquid Glass.

**Architecture:** Static JSON content bundled in-app decoded into Codable structs. SwiftData for mutable user state. CloudKit public database for leaderboards. ElevenLabs + AI API for external features. Liquid Glass design language with vibrant popping colors.

**Tech Stack:** SwiftUI, SwiftData, CloudKit, iOS 26 Liquid Glass, ElevenLabs API, Claude/OpenAI API

**Repo:** https://github.com/EliasMarine/lebanese-lessons-ios

**Versioning:** SemVer, Conventional Commits, feature branches → dev → main

---

## Phase 1: Project Foundation

### Task 1: Set Up Git Branching & Project Config

**Files:**
- Modify: `project.yml`

**Step 1: Create dev branch from main**

```bash
cd "/Volumes/ExtraStrg_RAID1/Mega Sync/Lebanese Lessons/lebanese-lessons-ios/.claude/worktrees/practical-jennings"
git checkout -b dev
```

**Step 2: Update project.yml deployment target to iOS 26**

Change `deploymentTarget.iOS` from `"17.0"` to `"26.0"` in `project.yml`.

**Step 3: Commit**

```bash
git add project.yml
git commit -m "chore: update deployment target to iOS 26"
```

---

### Task 2: Create Directory Structure

**Files:**
- Create directories under `LebaneseLearn/`

**Step 1: Create all new directories**

```bash
BASE="LebaneseLearn"
mkdir -p "$BASE/Models/Content"
mkdir -p "$BASE/Models/UserData"
mkdir -p "$BASE/Resources/Content/vocab"
mkdir -p "$BASE/Resources/Content/exercises"
mkdir -p "$BASE/Resources/Content/dialogues"
mkdir -p "$BASE/Resources/Content/grammar"
mkdir -p "$BASE/Resources/Content/shadowing"
mkdir -p "$BASE/Resources/Content/scenarios"
mkdir -p "$BASE/Resources/Content/verbs"
mkdir -p "$BASE/Resources/Content/culture"
mkdir -p "$BASE/Views/Onboarding"
mkdir -p "$BASE/Views/AI"
```

**Step 2: Commit**

```bash
git add -A
git commit -m "chore: create directory structure for local-first architecture"
```

---

## Phase 2: Content Conversion (TypeScript → JSON)

### Task 3: Write Content Export Script

**Files:**
- Create: `scripts/export-content.mjs`

**Step 1: Write a Node.js script that imports each TypeScript content module and exports to JSON**

This script reads from `/lebanese-lessons/src/content/` and outputs JSON files to `LebaneseLearn/Resources/Content/`.

```javascript
// scripts/export-content.mjs
// Run with: node --loader ts-node/esm scripts/export-content.mjs
// Or manually convert each TS file by:
// 1. Import the TS module
// 2. JSON.stringify the exported arrays
// 3. Write to Resources/Content/

import { writeFileSync, mkdirSync } from 'fs';
import { join } from 'path';

const CONTENT_SRC = '/Volumes/ExtraStrg_RAID1/Mega Sync/Lebanese Lessons/lebanese-lessons/src/content';
const OUTPUT_DIR = '/Volumes/ExtraStrg_RAID1/Mega Sync/Lebanese Lessons/lebanese-lessons-ios/.claude/worktrees/practical-jennings/LebaneseLearn/Resources/Content';

function writeJSON(path, data) {
    writeFileSync(join(OUTPUT_DIR, path), JSON.stringify(data, null, 2));
    console.log(`  Wrote ${path}`);
}

async function main() {
    // Phases
    const { phases } = await import(join(CONTENT_SRC, 'phases/index.ts'));
    writeJSON('phases.json', phases);

    // Per-phase content
    for (let i = 1; i <= 6; i++) {
        try {
            const vocab = await import(join(CONTENT_SRC, `vocab/phase${i}.ts`));
            const key = Object.keys(vocab).find(k => k.includes('Vocab'));
            if (key) writeJSON(`vocab/phase${i}.json`, vocab[key]);
        } catch(e) { console.log(`  No vocab for phase ${i}`); }

        try {
            const ex = await import(join(CONTENT_SRC, `exercises/phase${i}.ts`));
            const key = Object.keys(ex).find(k => k.includes('Exercises'));
            if (key) writeJSON(`exercises/phase${i}.json`, ex[key]);
        } catch(e) { console.log(`  No exercises for phase ${i}`); }

        try {
            const dlg = await import(join(CONTENT_SRC, `dialogues/phase${i}.ts`));
            const key = Object.keys(dlg).find(k => k.includes('Dialogues'));
            if (key) writeJSON(`dialogues/phase${i}.json`, dlg[key]);
        } catch(e) { console.log(`  No dialogues for phase ${i}`); }

        try {
            const gr = await import(join(CONTENT_SRC, `grammar/phase${i}.ts`));
            const key = Object.keys(gr).find(k => k.includes('Grammar'));
            if (key) writeJSON(`grammar/phase${i}.json`, gr[key]);
        } catch(e) { console.log(`  No grammar for phase ${i}`); }

        try {
            const cu = await import(join(CONTENT_SRC, `culture/phase${i}.ts`));
            const key = Object.keys(cu).find(k => k.includes('Culture'));
            if (key) writeJSON(`culture/phase${i}.json`, cu[key]);
        } catch(e) { console.log(`  No culture for phase ${i}`); }
    }

    // Shadowing (phases 1-3)
    for (let i = 1; i <= 3; i++) {
        try {
            const sh = await import(join(CONTENT_SRC, `shadowing/phase${i}.ts`));
            const key = Object.keys(sh).find(k => k.includes('Shadowing'));
            if (key) writeJSON(`shadowing/phase${i}.json`, sh[key]);
        } catch(e) { console.log(`  No shadowing for phase ${i}`); }
    }

    // Scenarios (phases 2-4)
    for (let i = 2; i <= 4; i++) {
        try {
            const sc = await import(join(CONTENT_SRC, `scenarios/phase${i}.ts`));
            const key = Object.keys(sc).find(k => k.includes('Scenarios'));
            if (key) writeJSON(`scenarios/phase${i}.json`, sc[key]);
        } catch(e) { console.log(`  No scenarios for phase ${i}`); }
    }

    // Verbs (phases 1-3)
    for (let i = 1; i <= 3; i++) {
        try {
            const v = await import(join(CONTENT_SRC, `verbs/phase${i}.ts`));
            const key = Object.keys(v).find(k => k.includes('Verbs'));
            if (key) writeJSON(`verbs/phase${i}.json`, v[key]);
        } catch(e) { console.log(`  No verbs for phase ${i}`); }
    }

    // Standalone files
    const { readingPassages } = await import(join(CONTENT_SRC, 'reading/index.ts'));
    writeJSON('reading.json', readingPassages);

    const proverbs = await import(join(CONTENT_SRC, 'proverbs/index.ts'));
    writeJSON('proverbs.json', proverbs.allProverbs);

    const { arabicRoots } = await import(join(CONTENT_SRC, 'roots.ts'));
    writeJSON('roots.json', arabicRoots);

    const { minimalPairs } = await import(join(CONTENT_SRC, 'minimal-pairs.ts'));
    writeJSON('minimal-pairs.json', minimalPairs);

    const { allMSAComparisons } = await import(join(CONTENT_SRC, 'msa-comparison/index.ts'));
    writeJSON('msa-comparison.json', allMSAComparisons);

    const { arabicAlphabet } = await import(join(CONTENT_SRC, 'sounds/phase1.ts'));
    writeJSON('sounds.json', arabicAlphabet);

    const { placementQuestions } = await import(join(CONTENT_SRC, 'placement-test.ts'));
    writeJSON('placement-test.json', placementQuestions);

    const journal = await import(join(CONTENT_SRC, 'journal/phase3.ts'));
    const jKey = Object.keys(journal).find(k => k.includes('Journal'));
    if (jKey) writeJSON('journal.json', journal[jKey]);

    console.log('Done!');
}

main().catch(console.error);
```

**Step 2: Run the export (or manually extract content)**

If the TS import approach has issues with bare TypeScript, alternatively write a simpler script that uses `tsx` or manually copy the data arrays from each `.ts` file, strip the TypeScript type annotations, and save as `.json`. The data is plain objects/arrays — no runtime logic.

**Step 3: Verify all JSON files are valid**

```bash
find LebaneseLearn/Resources/Content -name "*.json" -exec python3 -c "import json,sys; json.load(open(sys.argv[1])); print('OK:', sys.argv[1])" {} \;
```

**Step 4: Commit**

```bash
git add LebaneseLearn/Resources/Content/ scripts/
git commit -m "content: export all lesson content as bundled JSON files"
```

---

## Phase 3: Swift Content Models (Codable Structs)

### Task 4: Create Content Model Structs

**Files:**
- Create: `LebaneseLearn/Models/Content/Phase.swift` (replace existing)
- Create: `LebaneseLearn/Models/Content/VocabItem.swift`
- Create: `LebaneseLearn/Models/Content/ExerciseSet.swift`
- Create: `LebaneseLearn/Models/Content/Dialogue.swift`
- Create: `LebaneseLearn/Models/Content/GrammarRule.swift`
- Create: `LebaneseLearn/Models/Content/ShadowingItem.swift`
- Create: `LebaneseLearn/Models/Content/ScenarioLesson.swift`
- Create: `LebaneseLearn/Models/Content/VerbConjugation.swift`
- Create: `LebaneseLearn/Models/Content/CultureNote.swift`
- Create: `LebaneseLearn/Models/Content/ReadingPassage.swift`
- Create: `LebaneseLearn/Models/Content/ProverbItem.swift`
- Create: `LebaneseLearn/Models/Content/ArabicRoot.swift`
- Create: `LebaneseLearn/Models/Content/MinimalPairSet.swift`
- Create: `LebaneseLearn/Models/Content/MSAComparison.swift`
- Create: `LebaneseLearn/Models/Content/SoundItem.swift`
- Create: `LebaneseLearn/Models/Content/PlacementQuestion.swift`
- Create: `LebaneseLearn/Models/Content/JournalPrompt.swift`

**Step 1: Create all Codable structs**

Each struct mirrors the TypeScript type exactly. All are `Codable`, `Identifiable` (where applicable), and `Sendable`.

```swift
// Phase.swift
import Foundation

struct Phase: Codable, Identifiable, Sendable {
    let id: Int
    let slug: String
    let title: String
    let titleArabic: String
    let subtitle: String
    let description: String
    let estimatedWeeks: String
    let heroGradient: String
    let heroArabicWatermark: String
}
```

```swift
// VocabItem.swift
import Foundation

struct VocabItem: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let arabic: String
    let transliteration: String
    let english: String
    let partOfSpeech: String?
    let audioFile: String?
    let category: String?
    let notes: String?
    let exampleSentence: ExampleSentence?

    struct ExampleSentence: Codable, Sendable {
        let arabic: String
        let transliteration: String
        let english: String
    }
}
```

```swift
// ExerciseSet.swift
import Foundation

struct ExerciseSet: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let type: ExerciseContentType
    let questions: [QuizQuestion]?
    let fillBlanks: [FillBlankQuestion]?
    let matchingPairs: [MatchingPair]?
    let sentenceBuilderData: [SentenceBuilderItem]?

    enum ExerciseContentType: String, Codable, Sendable {
        case multipleChoice = "multiple-choice"
        case fillBlank = "fill-blank"
        case matching = "matching"
        case sentenceBuilder = "sentence-builder"
        case dictation = "dictation"
    }
}

struct QuizQuestion: Codable, Identifiable, Sendable {
    let id: String
    let prompt: String
    let promptArabic: String?
    let options: [String]
    let correctIndex: Int
    let explanation: String?
}

struct FillBlankQuestion: Codable, Identifiable, Sendable {
    let id: String
    let sentence: String
    let blank: String
    let answer: String
    let acceptableAnswers: [String]?
    let hint: String?
}

struct MatchingPair: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
}

struct SentenceBuilderItem: Codable, Sendable {
    let words: [String]
    let correctOrder: [Int]
    let english: String
}
```

```swift
// Dialogue.swift
import Foundation

struct Dialogue: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let context: String?
    let lines: [DialogueLine]
}

struct DialogueLine: Codable, Sendable {
    let speaker: String
    let speakerRole: String  // "a" or "b"
    let arabic: String
    let transliteration: String
    let english: String
    let audioFile: String?
}
```

```swift
// GrammarRule.swift
import Foundation

struct GrammarRule: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let tag: String?
    let explanation: String
    let examples: [GrammarExample]?
    let table: GrammarTable?
}

struct GrammarExample: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
    let breakdown: String?
}

struct GrammarTable: Codable, Sendable {
    let headers: [String]
    let rows: [[String]]
}
```

```swift
// ShadowingItem.swift
import Foundation

struct ShadowingItem: Codable, Identifiable, Sendable {
    let id: String
    let arabic: String
    let transliteration: String
    let english: String
    let audioFile: String?
    let steps: [String]
}
```

```swift
// ScenarioLesson.swift
import Foundation

struct ScenarioLesson: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let titleArabic: String
    let setting: String
    let branches: [ScenarioBranch]
    let comprehensionCheck: [ComprehensionQuestion]?
    let vocabSummary: [VocabSummaryItem]
}

struct ScenarioBranch: Codable, Identifiable, Sendable {
    let id: String
    let speaker: String
    let speakerRole: String  // "a", "b", or "narrator"
    let arabic: String
    let transliteration: String
    let english: String
    let choices: [ScenarioChoice]?
    let culturalTip: String?
}

struct ScenarioChoice: Codable, Sendable {
    let text: String
    let textArabic: String
    let textTransliteration: String
    let nextBranchId: String
    let culturalNote: String?
}

struct ComprehensionQuestion: Codable, Sendable {
    let question: String
    let options: [String]
    let correctIndex: Int
}

struct VocabSummaryItem: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
}
```

```swift
// VerbConjugation.swift
import Foundation

struct VerbConjugation: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let verb: String
    let verbArabic: String
    let meaning: String
    let pastTense: ConjugationSet
    let presentTense: ConjugationSet
    let imperative: ImperativeSet?
    let exampleSentences: [VerbExample]
}

struct ConjugationSet: Codable, Sendable {
    let ana: String
    let enta: String
    let ente: String
    let huwwe: String
    let hiyye: String
    let ne7na: String
    let ento: String
    let henne: String
}

struct ImperativeSet: Codable, Sendable {
    let singularM: String
    let singularF: String
    let plural: String

    enum CodingKeys: String, CodingKey {
        case singularM = "singular_m"
        case singularF = "singular_f"
        case plural
    }
}

struct VerbExample: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
}
```

```swift
// CultureNote.swift
import Foundation

struct CultureNote: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let content: String
    let items: [CultureItem]?
}

struct CultureItem: Codable, Sendable {
    let label: String
    let value: String
    let origin: String?
}
```

```swift
// ReadingPassage.swift
import Foundation

struct ReadingPassage: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let title: String
    let titleArabic: String
    let level: String  // "beginner", "intermediate", "advanced"
    let arabic: String
    let transliteration: String
    let english: String
    let vocabHighlights: [VocabHighlight]?
    let comprehensionQuestions: [ReadingQuestion]?
}

struct VocabHighlight: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
}

struct ReadingQuestion: Codable, Sendable {
    let question: String
    let answer: String
}
```

```swift
// ProverbItem.swift
import Foundation

struct ProverbItem: Codable, Identifiable, Sendable {
    let id: String
    let arabic: String
    let transliteration: String
    let english: String
    let meaning: String
}
```

```swift
// ArabicRoot.swift
import Foundation

struct ArabicRoot: Codable, Identifiable, Sendable {
    let id: String
    let root: String
    let rootLetters: String
    let meaning: String
    let words: [RootWord]
}

struct RootWord: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
    let form: String?
    let partOfSpeech: String
}
```

```swift
// MinimalPairSet.swift
import Foundation

struct MinimalPairSet: Codable, Identifiable, Sendable {
    let id: String
    let sound1: SoundDescription
    let sound2: SoundDescription
    let tip: String
    let examples: [MinimalPairExample]
}

struct SoundDescription: Codable, Sendable {
    let letter: String
    let name: String
    let description: String
}

struct MinimalPairExample: Codable, Sendable {
    let word1: WordEntry
    let word2: WordEntry
}

struct WordEntry: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let english: String
}
```

```swift
// MSAComparison.swift
import Foundation

struct MSAComparison: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let category: String
    let items: [MSAComparisonItem]
}

struct MSAComparisonItem: Codable, Sendable {
    let concept: String
    let msa: LanguageVariant
    let lebanese: LanguageVariant
    let notes: String
}

struct LanguageVariant: Codable, Sendable {
    let arabic: String
    let transliteration: String
}
```

```swift
// SoundItem.swift
import Foundation

struct SoundItem: Codable, Sendable {
    let letter: String
    let name: String
    let description: String
    let exampleArabic: String?
    let exampleTransliteration: String?
    let exampleEnglish: String?
}

struct LetterForm: Codable, Sendable {
    let letter: String
    let name: String
    let isolated: String
    let initial: String
    let medial: String
    let final: String
}
```

```swift
// PlacementQuestion.swift
import Foundation

struct PlacementQuestion: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let prompt: String
    let promptArabic: String?
    let options: [String]
    let correctIndex: Int
    let explanation: String
}
```

```swift
// JournalPrompt.swift
import Foundation

struct JournalPrompt: Codable, Identifiable, Sendable {
    let id: String
    let phaseId: Int
    let arabic: String
    let transliteration: String
    let english: String
    let exampleResponse: String?
}
```

**Step 2: Delete the old Models/Phase.swift** (replaced by Models/Content/Phase.swift with new fields)

**Step 3: Commit**

```bash
git add LebaneseLearn/Models/Content/
git commit -m "feat: add Codable content model structs for all 17 content types"
```

---

### Task 5: Create ContentManager Service

**Files:**
- Create: `LebaneseLearn/Services/ContentManager.swift`

**Step 1: Write ContentManager**

```swift
// ContentManager.swift
import Foundation

@Observable
final class ContentManager: Sendable {
    static let shared = ContentManager()

    // MARK: - Cached content
    private var phasesCache: [Phase]?
    private var vocabCache: [Int: [VocabItem]] = [:]
    private var exercisesCache: [Int: [ExerciseSet]] = [:]
    private var dialoguesCache: [Int: [Dialogue]] = [:]
    private var grammarCache: [Int: [GrammarRule]] = [:]
    private var shadowingCache: [Int: [ShadowingItem]] = [:]
    private var scenariosCache: [Int: [ScenarioLesson]] = [:]
    private var verbsCache: [Int: [VerbConjugation]] = [:]
    private var cultureCache: [Int: [CultureNote]] = [:]

    // MARK: - Phases

    func phases() -> [Phase] {
        if let cached = phasesCache { return cached }
        let loaded: [Phase] = load("phases")
        phasesCache = loaded
        return loaded
    }

    // MARK: - Per-phase content

    func vocab(for phaseId: Int) -> [VocabItem] {
        if let cached = vocabCache[phaseId] { return cached }
        let loaded: [VocabItem] = load("vocab/phase\(phaseId)")
        vocabCache[phaseId] = loaded
        return loaded
    }

    func exercises(for phaseId: Int) -> [ExerciseSet] {
        if let cached = exercisesCache[phaseId] { return cached }
        let loaded: [ExerciseSet] = load("exercises/phase\(phaseId)")
        exercisesCache[phaseId] = loaded
        return loaded
    }

    func dialogues(for phaseId: Int) -> [Dialogue] {
        if let cached = dialoguesCache[phaseId] { return cached }
        let loaded: [Dialogue] = load("dialogues/phase\(phaseId)")
        dialoguesCache[phaseId] = loaded
        return loaded
    }

    func grammar(for phaseId: Int) -> [GrammarRule] {
        if let cached = grammarCache[phaseId] { return cached }
        let loaded: [GrammarRule] = load("grammar/phase\(phaseId)")
        grammarCache[phaseId] = loaded
        return loaded
    }

    func shadowing(for phaseId: Int) -> [ShadowingItem] {
        if let cached = shadowingCache[phaseId] { return cached }
        let loaded: [ShadowingItem] = load("shadowing/phase\(phaseId)")
        shadowingCache[phaseId] = loaded
        return loaded
    }

    func scenarios(for phaseId: Int) -> [ScenarioLesson] {
        if let cached = scenariosCache[phaseId] { return cached }
        let loaded: [ScenarioLesson] = load("scenarios/phase\(phaseId)")
        scenariosCache[phaseId] = loaded
        return loaded
    }

    func verbs(for phaseId: Int) -> [VerbConjugation] {
        if let cached = verbsCache[phaseId] { return cached }
        let loaded: [VerbConjugation] = load("verbs/phase\(phaseId)")
        verbsCache[phaseId] = loaded
        return loaded
    }

    func culture(for phaseId: Int) -> [CultureNote] {
        if let cached = cultureCache[phaseId] { return cached }
        let loaded: [CultureNote] = load("culture/phase\(phaseId)")
        cultureCache[phaseId] = loaded
        return loaded
    }

    // MARK: - Standalone content

    func readingPassages() -> [ReadingPassage] { load("reading") }
    func proverbs() -> [ProverbItem] { load("proverbs") }
    func roots() -> [ArabicRoot] { load("roots") }
    func minimalPairs() -> [MinimalPairSet] { load("minimal-pairs") }
    func msaComparisons() -> [MSAComparison] { load("msa-comparison") }
    func sounds() -> [SoundItem] { load("sounds") }
    func placementTest() -> [PlacementQuestion] { load("placement-test") }
    func journalPrompts() -> [JournalPrompt] { load("journal") }

    // MARK: - Helpers

    /// All vocab across all phases
    func allVocab() -> [VocabItem] {
        (1...6).flatMap { vocab(for: $0) }
    }

    // MARK: - JSON Loading

    private func load<T: Decodable>(_ name: String) -> [T] {
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "json",
            subdirectory: "Content"
        ) else {
            print("ContentManager: Missing \(name).json")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([T].self, from: data)
        } catch {
            print("ContentManager: Failed to decode \(name).json — \(error)")
            return []
        }
    }
}
```

**Step 2: Commit**

```bash
git add LebaneseLearn/Services/ContentManager.swift
git commit -m "feat: add ContentManager for loading bundled JSON content"
```

---

## Phase 4: SwiftData User Models

### Task 6: Create SwiftData Models

**Files:**
- Create: `LebaneseLearn/Models/UserData/UserProfile.swift`
- Create: `LebaneseLearn/Models/UserData/LessonProgressRecord.swift`
- Create: `LebaneseLearn/Models/UserData/SRSCardRecord.swift`
- Create: `LebaneseLearn/Models/UserData/ExerciseResultRecord.swift`
- Create: `LebaneseLearn/Models/UserData/EarnedBadge.swift`
- Create: `LebaneseLearn/Models/UserData/XPEntry.swift`
- Create: `LebaneseLearn/Models/UserData/DailyActivityRecord.swift`
- Create: `LebaneseLearn/Models/UserData/CompletedItemRecord.swift`
- Create: `LebaneseLearn/Models/UserData/AIConversationRecord.swift`

**Step 1: Create all SwiftData models**

```swift
// UserProfile.swift
import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var totalXP: Int
    var level: Int
    var levelTitle: String
    var currentXPInLevel: Int
    var xpNeededForLevel: Int
    var streak: Int
    var longestStreak: Int
    var studyGoalMinutes: Int
    var lastStudyDate: Date?
    var hasCompletedOnboarding: Bool
    var createdAt: Date

    init(
        name: String,
        totalXP: Int = 0,
        level: Int = 1,
        levelTitle: String = "Beginner",
        currentXPInLevel: Int = 0,
        xpNeededForLevel: Int = 200,
        streak: Int = 0,
        longestStreak: Int = 0,
        studyGoalMinutes: Int = 10,
        hasCompletedOnboarding: Bool = false
    ) {
        self.name = name
        self.totalXP = totalXP
        self.level = level
        self.levelTitle = levelTitle
        self.currentXPInLevel = currentXPInLevel
        self.xpNeededForLevel = xpNeededForLevel
        self.streak = streak
        self.longestStreak = longestStreak
        self.studyGoalMinutes = studyGoalMinutes
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.lastStudyDate = nil
        self.createdAt = .now
    }
}
```

```swift
// LessonProgressRecord.swift
import Foundation
import SwiftData

@Model
final class LessonProgressRecord {
    #Unique<LessonProgressRecord>([\.phaseId, \.exerciseSetId])

    var phaseId: Int
    var exerciseSetId: String
    var completed: Bool
    var bestScore: Int
    var attempts: Int
    var lastAttemptDate: Date

    init(phaseId: Int, exerciseSetId: String) {
        self.phaseId = phaseId
        self.exerciseSetId = exerciseSetId
        self.completed = false
        self.bestScore = 0
        self.attempts = 0
        self.lastAttemptDate = .now
    }
}
```

```swift
// SRSCardRecord.swift
import Foundation
import SwiftData

@Model
final class SRSCardRecord {
    #Unique<SRSCardRecord>([\.vocabItemId])

    var vocabItemId: String
    var phaseId: Int
    var easeFactor: Double
    var interval: Int  // days
    var repetitions: Int
    var nextReviewAt: Date
    var lastReviewedAt: Date?
    var createdAt: Date

    init(vocabItemId: String, phaseId: Int) {
        self.vocabItemId = vocabItemId
        self.phaseId = phaseId
        self.easeFactor = 2.5
        self.interval = 0
        self.repetitions = 0
        self.nextReviewAt = .now
        self.lastReviewedAt = nil
        self.createdAt = .now
    }
}
```

```swift
// ExerciseResultRecord.swift
import Foundation
import SwiftData

@Model
final class ExerciseResultRecord {
    var phaseId: Int
    var exerciseSetId: String
    var exerciseType: String
    var score: Int
    var totalQuestions: Int
    var correctAnswers: Int
    var timeSpentSeconds: Int
    var completedAt: Date

    init(
        phaseId: Int,
        exerciseSetId: String,
        exerciseType: String,
        score: Int,
        totalQuestions: Int,
        correctAnswers: Int,
        timeSpentSeconds: Int
    ) {
        self.phaseId = phaseId
        self.exerciseSetId = exerciseSetId
        self.exerciseType = exerciseType
        self.score = score
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.timeSpentSeconds = timeSpentSeconds
        self.completedAt = .now
    }
}
```

```swift
// EarnedBadge.swift
import Foundation
import SwiftData

@Model
final class EarnedBadge {
    #Unique<EarnedBadge>([\.badgeId])

    var badgeId: String
    var earnedAt: Date

    init(badgeId: String) {
        self.badgeId = badgeId
        self.earnedAt = .now
    }
}
```

```swift
// XPEntry.swift
import Foundation
import SwiftData

@Model
final class XPEntry {
    var amount: Int
    var source: String  // "exercise", "review", "streak_bonus", "badge", "daily_challenge"
    var sourceId: String?
    var earnedAt: Date

    init(amount: Int, source: String, sourceId: String? = nil) {
        self.amount = amount
        self.source = source
        self.sourceId = sourceId
        self.earnedAt = .now
    }
}
```

```swift
// DailyActivityRecord.swift
import Foundation
import SwiftData

@Model
final class DailyActivityRecord {
    #Unique<DailyActivityRecord>([\.date])

    var date: String  // "YYYY-MM-DD" format for uniqueness
    var minutesStudied: Int
    var cardsReviewed: Int
    var exercisesCompleted: Int

    init(date: String) {
        self.date = date
        self.minutesStudied = 0
        self.cardsReviewed = 0
        self.exercisesCompleted = 0
    }
}
```

```swift
// CompletedItemRecord.swift
import Foundation
import SwiftData

@Model
final class CompletedItemRecord {
    #Unique<CompletedItemRecord>([\.phaseId, \.tab, \.itemId])

    var phaseId: Int
    var tab: String  // "vocab", "exercises", "dialogues", "grammar", etc.
    var itemId: String
    var completedAt: Date

    init(phaseId: Int, tab: String, itemId: String) {
        self.phaseId = phaseId
        self.tab = tab
        self.itemId = itemId
        self.completedAt = .now
    }
}
```

```swift
// AIConversationRecord.swift
import Foundation
import SwiftData

@Model
final class AIConversationRecord {
    var phaseId: Int
    var title: String
    var messagesJSON: String  // JSON-encoded array of messages
    var createdAt: Date
    var updatedAt: Date

    init(phaseId: Int, title: String, messagesJSON: String = "[]") {
        self.phaseId = phaseId
        self.title = title
        self.messagesJSON = messagesJSON
        self.createdAt = .now
        self.updatedAt = .now
    }
}
```

**Step 2: Commit**

```bash
git add LebaneseLearn/Models/UserData/
git commit -m "feat: add SwiftData models for all user state"
```

---

### Task 7: Set Up SwiftData Container in App Entry Point

**Files:**
- Modify: `LebaneseLearn/App/LebaneseLearnApp.swift`

**Step 1: Update app entry point**

Replace the current `LebaneseLearnApp.swift` with:

```swift
import SwiftUI
import SwiftData

@main
struct LebaneseLearnApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            UserProfile.self,
            LessonProgressRecord.self,
            SRSCardRecord.self,
            ExerciseResultRecord.self,
            EarnedBadge.self,
            XPEntry.self,
            DailyActivityRecord.self,
            CompletedItemRecord.self,
            AIConversationRecord.self,
        ])
    }
}
```

**Step 2: Commit**

```bash
git add LebaneseLearn/App/LebaneseLearnApp.swift
git commit -m "feat: configure SwiftData model container in app entry"
```

---

## Phase 5: Core Services

### Task 8: Create SRS Engine (SM-2 Algorithm)

**Files:**
- Create: `LebaneseLearn/Services/SRSEngine.swift`

**Step 1: Implement SM-2 algorithm**

```swift
// SRSEngine.swift
import Foundation
import SwiftData

struct SRSEngine {
    /// SM-2 spaced repetition algorithm
    /// Rating: 1 = Again, 2 = Hard, 3 = Good, 4 = Easy, 5 = Perfect
    static func processReview(card: SRSCardRecord, rating: Int) {
        let q = Double(max(0, min(rating, 5)))

        if q < 3 {
            // Failed — reset
            card.repetitions = 0
            card.interval = 0
        } else {
            // Passed
            switch card.repetitions {
            case 0: card.interval = 1
            case 1: card.interval = 6
            default: card.interval = Int(Double(card.interval) * card.easeFactor)
            }
            card.repetitions += 1
        }

        // Update ease factor (minimum 1.3)
        card.easeFactor = max(1.3, card.easeFactor + 0.1 - (5.0 - q) * (0.08 + (5.0 - q) * 0.02))

        // Schedule next review
        card.lastReviewedAt = .now
        card.nextReviewAt = Calendar.current.date(byAdding: .day, value: max(1, card.interval), to: .now) ?? .now
    }

    /// Seed SRS cards from a phase's vocabulary
    static func seedCards(from vocab: [VocabItem], phaseId: Int, context: ModelContext) {
        for item in vocab {
            let descriptor = FetchDescriptor<SRSCardRecord>(
                predicate: #Predicate { $0.vocabItemId == item.id }
            )
            let existing = (try? context.fetchCount(descriptor)) ?? 0
            if existing == 0 {
                let card = SRSCardRecord(vocabItemId: item.id, phaseId: phaseId)
                context.insert(card)
            }
        }
        try? context.save()
    }
}
```

**Step 2: Commit**

```bash
git add LebaneseLearn/Services/SRSEngine.swift
git commit -m "feat: add SM-2 spaced repetition engine"
```

---

### Task 9: Create XP Engine

**Files:**
- Create: `LebaneseLearn/Services/XPEngine.swift`

**Step 1: Implement XP/level system**

```swift
// XPEngine.swift
import Foundation
import SwiftData

struct XPEngine {
    struct LevelInfo {
        let level: Int
        let title: String
        let xpRequired: Int
    }

    static let levels: [LevelInfo] = [
        LevelInfo(level: 1, title: "Beginner", xpRequired: 0),
        LevelInfo(level: 2, title: "Explorer", xpRequired: 200),
        LevelInfo(level: 3, title: "Apprentice", xpRequired: 500),
        LevelInfo(level: 4, title: "Speaker", xpRequired: 1000),
        LevelInfo(level: 5, title: "Conversationalist", xpRequired: 1800),
        LevelInfo(level: 6, title: "Storyteller", xpRequired: 3000),
        LevelInfo(level: 7, title: "Fluent", xpRequired: 5000),
        LevelInfo(level: 8, title: "Native-like", xpRequired: 8000),
        LevelInfo(level: 9, title: "Master", xpRequired: 12000),
        LevelInfo(level: 10, title: "Legend", xpRequired: 20000),
    ]

    static func awardXP(
        amount: Int,
        source: String,
        sourceId: String? = nil,
        profile: UserProfile,
        context: ModelContext
    ) {
        // Record XP entry
        let entry = XPEntry(amount: amount, source: source, sourceId: sourceId)
        context.insert(entry)

        // Update profile
        profile.totalXP += amount

        // Check for level up
        let newLevel = levels.last(where: { $0.xpRequired <= profile.totalXP }) ?? levels[0]
        profile.level = newLevel.level
        profile.levelTitle = newLevel.title

        // Calculate progress within current level
        let nextLevel = levels.first(where: { $0.xpRequired > profile.totalXP })
        if let next = nextLevel {
            let currentLevelXP = newLevel.xpRequired
            profile.currentXPInLevel = profile.totalXP - currentLevelXP
            profile.xpNeededForLevel = next.xpRequired - currentLevelXP
        } else {
            profile.currentXPInLevel = profile.totalXP
            profile.xpNeededForLevel = profile.totalXP
        }

        try? context.save()
    }

    /// Update daily streak
    static func updateStreak(profile: UserProfile) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        if let lastStudy = profile.lastStudyDate {
            let lastDay = calendar.startOfDay(for: lastStudy)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if diff == 1 {
                profile.streak += 1
                profile.longestStreak = max(profile.longestStreak, profile.streak)
            } else if diff > 1 {
                profile.streak = 1
            }
            // diff == 0: same day, no change
        } else {
            profile.streak = 1
        }
        profile.lastStudyDate = .now
    }
}
```

**Step 2: Commit**

```bash
git add LebaneseLearn/Services/XPEngine.swift
git commit -m "feat: add XP and leveling engine"
```

---

### Task 10: Create ElevenLabs TTS Service

**Files:**
- Create: `LebaneseLearn/Services/ElevenLabsService.swift`
- Create: `LebaneseLearn/Services/KeychainHelper.swift`

**Step 1: Create Keychain helper**

```swift
// KeychainHelper.swift
import Foundation
import Security

enum KeychainHelper {
    static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
```

**Step 2: Create ElevenLabs service**

```swift
// ElevenLabsService.swift
import Foundation
import AVFoundation

actor ElevenLabsService {
    static let shared = ElevenLabsService()

    private static let keychainKey = "com.lebaneselearn.elevenlabs.apiKey"
    private static let voiceIdKey = "com.lebaneselearn.elevenlabs.voiceId"
    private let cacheDir: URL
    private var audioPlayer: AVAudioPlayer?

    init() {
        let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDir = cache.appendingPathComponent("tts-cache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    // MARK: - API Key Management

    nonisolated func setAPIKey(_ key: String) {
        KeychainHelper.save(key: Self.keychainKey, value: key)
    }

    nonisolated func setVoiceId(_ voiceId: String) {
        KeychainHelper.save(key: Self.voiceIdKey, value: voiceId)
    }

    nonisolated private func apiKey() -> String? {
        KeychainHelper.load(key: Self.keychainKey)
    }

    nonisolated private func voiceId() -> String? {
        KeychainHelper.load(key: Self.voiceIdKey)
    }

    // MARK: - TTS

    func speak(_ text: String) async throws -> Data {
        // Check cache first
        let cacheKey = text.data(using: .utf8)!.base64EncodedString()
            .prefix(64)
            .replacingOccurrences(of: "/", with: "_")
        let cacheFile = cacheDir.appendingPathComponent("\(cacheKey).mp3")

        if FileManager.default.fileExists(atPath: cacheFile.path) {
            return try Data(contentsOf: cacheFile)
        }

        // Call ElevenLabs API
        guard let key = apiKey(), let voice = voiceId() else {
            throw TTSError.missingCredentials
        }

        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voice)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "xi-api-key")
        request.httpBody = try JSONEncoder().encode([
            "text": text,
            "model_id": "eleven_multilingual_v2",
        ])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TTSError.apiError
        }

        // Cache the audio
        try data.write(to: cacheFile)
        return data
    }

    enum TTSError: Error {
        case missingCredentials
        case apiError
    }
}
```

**Step 3: Commit**

```bash
git add LebaneseLearn/Services/KeychainHelper.swift LebaneseLearn/Services/ElevenLabsService.swift
git commit -m "feat: add ElevenLabs TTS service with caching and Keychain storage"
```

---

### Task 11: Create AI Service

**Files:**
- Create: `LebaneseLearn/Services/AIService.swift`

**Step 1: Implement AI service**

```swift
// AIService.swift
import Foundation

actor AIService {
    static let shared = AIService()

    private static let keychainKey = "com.lebaneselearn.ai.apiKey"
    private let baseURL = "https://api.anthropic.com/v1/messages"

    struct Message: Codable, Sendable {
        let role: String  // "user" or "assistant"
        let content: String
    }

    nonisolated func setAPIKey(_ key: String) {
        KeychainHelper.save(key: Self.keychainKey, value: key)
    }

    nonisolated private func apiKey() -> String? {
        KeychainHelper.load(key: Self.keychainKey)
    }

    /// Send a single prompt with system instructions
    func ask(
        prompt: String,
        systemPrompt: String = "You are a Lebanese Arabic language tutor. Respond helpfully with examples in Arabic script, transliteration, and English. Keep responses concise."
    ) async throws -> String {
        try await send(messages: [Message(role: "user", content: prompt)], system: systemPrompt)
    }

    /// Continue a conversation
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

    enum AIError: Error {
        case missingAPIKey
        case apiError
    }
}
```

**Step 2: Commit**

```bash
git add LebaneseLearn/Services/AIService.swift
git commit -m "feat: add AI service for conversation practice and grammar help"
```

---

### Task 12: Create CloudKit Leaderboard Service

**Files:**
- Create: `LebaneseLearn/Services/CloudKitService.swift`

**Step 1: Implement CloudKit leaderboard**

```swift
// CloudKitService.swift
import Foundation
import CloudKit

@Observable
final class CloudKitService {
    static let shared = CloudKitService()

    private let container = CKContainer.default()
    private var database: CKDatabase { container.publicCloudDatabase }

    struct LeaderboardEntry: Identifiable, Sendable {
        let id: String
        let rank: Int
        let name: String
        let totalXP: Int
        let level: Int
        let levelTitle: String
        var isCurrentUser: Bool = false
    }

    private(set) var entries: [LeaderboardEntry] = []
    private(set) var currentUserRank: Int?
    private(set) var isLoading = false

    func fetchLeaderboard() async {
        isLoading = true
        defer { isLoading = false }

        let query = CKQuery(recordType: "LeaderboardEntry", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "totalXP", ascending: false)]

        do {
            let (results, _) = try await database.records(matching: query, resultsLimit: 50)
            var ranked: [LeaderboardEntry] = []
            var rank = 1

            for (_, result) in results {
                if let record = try? result.get() {
                    ranked.append(LeaderboardEntry(
                        id: record.recordID.recordName,
                        rank: rank,
                        name: record["userName"] as? String ?? "Unknown",
                        totalXP: record["totalXP"] as? Int ?? 0,
                        level: record["level"] as? Int ?? 1,
                        levelTitle: record["levelTitle"] as? String ?? "Beginner"
                    ))
                    rank += 1
                }
            }
            entries = ranked
        } catch {
            print("CloudKit fetch error: \(error)")
        }
    }

    func updateScore(profile: UserProfile) async {
        let recordID = CKRecord.ID(recordName: "user-\(profile.name.lowercased().replacingOccurrences(of: " ", with: "-"))")
        let record: CKRecord

        do {
            record = try await database.record(for: recordID)
        } catch {
            record = CKRecord(recordType: "LeaderboardEntry", recordID: recordID)
        }

        record["userName"] = profile.name
        record["totalXP"] = profile.totalXP
        record["level"] = profile.level
        record["levelTitle"] = profile.levelTitle

        do {
            try await database.save(record)
        } catch {
            print("CloudKit save error: \(error)")
        }
    }
}
```

**Step 2: Commit**

```bash
git add LebaneseLearn/Services/CloudKitService.swift
git commit -m "feat: add CloudKit leaderboard service"
```

---

### Task 13: Update AudioService for Local + ElevenLabs

**Files:**
- Modify: `LebaneseLearn/Services/AudioService.swift`

**Step 1: Rewrite AudioService to use ElevenLabs with AVSpeechSynthesizer fallback**

```swift
// AudioService.swift
import Foundation
import AVFoundation

@Observable
final class AudioService: NSObject, AVAudioPlayerDelegate, Sendable {
    static let shared = AudioService()

    private var audioPlayer: AVAudioPlayer?
    private(set) var isPlaying = false

    /// Speak Arabic text using ElevenLabs, falling back to system voice
    func speak(_ text: String) async {
        do {
            let audioData = try await ElevenLabsService.shared.speak(text)
            await playData(audioData)
        } catch {
            // Fallback to system TTS
            await speakWithSystem(text)
        }
    }

    /// Play audio data (MP3)
    @MainActor
    private func playData(_ data: Data) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            isPlaying = true
            audioPlayer?.play()
        } catch {
            print("AudioService: playback error — \(error)")
            isPlaying = false
        }
    }

    /// System TTS fallback
    @MainActor
    private func speakWithSystem(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ar-001")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }

    /// Play a bundled sound effect by name
    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("AudioService: sound error — \(error)")
        }
    }

    // MARK: - AVAudioPlayerDelegate

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
        }
    }
}
```

**Step 2: Commit**

```bash
git add LebaneseLearn/Services/AudioService.swift
git commit -m "feat: rewrite AudioService for ElevenLabs TTS with system fallback"
```

---

## Phase 6: Remove Server Dependencies

### Task 14: Remove Old API-Dependent Services

**Files:**
- Delete: `LebaneseLearn/Services/APIService.swift`
- Delete: `LebaneseLearn/Services/AuthService.swift`
- Delete: `LebaneseLearn/Services/LessonService.swift`
- Delete: `LebaneseLearn/Services/ReviewService.swift`
- Delete: `LebaneseLearn/Services/LeaderboardService.swift`
- Delete: `LebaneseLearn/Models/User.swift` (replaced by SwiftData UserProfile)
- Delete: `LebaneseLearn/Views/Auth/LoginView.swift`
- Delete: `LebaneseLearn/Views/Auth/RegisterView.swift`

**Step 1: Remove all server-dependent files**

```bash
rm LebaneseLearn/Services/APIService.swift
rm LebaneseLearn/Services/AuthService.swift
rm LebaneseLearn/Services/LessonService.swift
rm LebaneseLearn/Services/ReviewService.swift
rm LebaneseLearn/Services/LeaderboardService.swift
rm LebaneseLearn/Models/User.swift
rm LebaneseLearn/Views/Auth/LoginView.swift
rm LebaneseLearn/Views/Auth/RegisterView.swift
```

**Step 2: Move old Phase.swift and Exercise.swift to avoid conflicts**

The old `Models/Phase.swift` and `Models/Exercise.swift` had server-oriented models. Delete them since we have new content models in `Models/Content/`.

```bash
rm LebaneseLearn/Models/Phase.swift
rm LebaneseLearn/Models/Exercise.swift
rm LebaneseLearn/Models/SRSCard.swift
rm LebaneseLearn/Models/Leaderboard.swift
```

Keep `Models/Badge.swift` — update it to be a static content definition (badges are earned locally now).

**Step 3: Commit**

```bash
git add -A
git commit -m "refactor: remove all server-dependent services and models"
```

---

## Phase 7: UI Overhaul — Liquid Glass + Vibrant Colors

### Task 15: Update Theme for Liquid Glass with Popping Colors

**Files:**
- Modify: `LebaneseLearn/Theme/Theme.swift`

**Step 1: Update Theme with vibrant colors and Liquid Glass helpers**

Keep the existing brand color system but make colors more vibrant and add Liquid Glass convenience modifiers. The coral `#E94560` stays as brand. Add vivid complementary colors that pop against glass backgrounds:

- Brand Coral: `#E94560`
- Electric Blue: `#00D2FF`
- Vivid Green: `#00E676`
- Hot Pink: `#FF1493`
- Golden Yellow: `#FFD600`
- Bright Purple: `#B388FF`
- Sunset Orange: `#FF6D00`

Add gradient definitions for phase cards and backgrounds. Add `.glassCard()` and `.glassButton()` view modifier helpers that wrap the Liquid Glass API for consistent usage.

**Step 2: Commit**

```bash
git add LebaneseLearn/Theme/Theme.swift
git commit -m "feat: update theme with vibrant popping colors and Liquid Glass helpers"
```

---

### Task 16: Create Onboarding Flow

**Files:**
- Create: `LebaneseLearn/Views/Onboarding/OnboardingView.swift`
- Create: `LebaneseLearn/Views/Onboarding/WelcomeStepView.swift`
- Create: `LebaneseLearn/Views/Onboarding/NameStepView.swift`
- Create: `LebaneseLearn/Views/Onboarding/GoalStepView.swift`
- Create: `LebaneseLearn/Views/Onboarding/PlacementStepView.swift`

**Step 1: Create onboarding flow**

Multi-step onboarding with Liquid Glass styling:
1. Welcome screen — app branding, "Get Started" button
2. Name entry — "What should we call you?"
3. Study goal — select daily minutes (5, 10, 15, 20, 30)
4. Optional placement test — "Know some Lebanese already?" Yes/Skip

On completion: create `UserProfile` in SwiftData, set `hasCompletedOnboarding = true`.

Each step uses `.glassEffect()` cards with vibrant accent colors, smooth page transitions.

**Step 2: Commit**

```bash
git add LebaneseLearn/Views/Onboarding/
git commit -m "feat: add Liquid Glass onboarding flow"
```

---

### Task 17: Update ContentView for Local Flow

**Files:**
- Modify: `LebaneseLearn/App/ContentView.swift`

**Step 1: Replace auth-based routing with onboarding check**

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        if let profile, profile.hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}
```

**Step 2: Commit**

```bash
git add LebaneseLearn/App/ContentView.swift
git commit -m "feat: replace auth routing with local onboarding check"
```

---

### Task 18: Update MainTabView with Liquid Glass

**Files:**
- Modify: `LebaneseLearn/Views/Dashboard/MainTabView.swift`

**Step 1: Apply Liquid Glass to tab bar**

Update the TabView to use Liquid Glass styling. Use `.glassEffect()` on the tab bar, vibrant SF Symbol icons with the brand accent tint.

**Step 2: Commit**

```bash
git add LebaneseLearn/Views/Dashboard/MainTabView.swift
git commit -m "feat: apply Liquid Glass to main tab navigation"
```

---

### Task 19: Rebuild DashboardView with Local Data

**Files:**
- Modify: `LebaneseLearn/Views/Dashboard/DashboardView.swift`

**Step 1: Rewrite to use SwiftData queries**

Replace API calls with `@Query` for UserProfile, DailyActivityRecord, etc. Show:
- Streak count, XP, level from UserProfile
- Daily challenges (locally generated based on activity)
- Recent activity from DailyActivityRecord
- All with Liquid Glass card styling and vibrant colors

**Step 2: Commit**

```bash
git add LebaneseLearn/Views/Dashboard/DashboardView.swift
git commit -m "feat: rebuild dashboard with SwiftData and Liquid Glass"
```

---

### Task 20: Rebuild LessonsListView with Content Tabs

**Files:**
- Modify: `LebaneseLearn/Views/Exercises/LessonsListView.swift`

**Step 1: Rewrite to show phases from ContentManager with content type tabs**

Each phase expands to show tabs: Vocab, Exercises, Dialogues, Grammar, Culture, etc. Content loaded from `ContentManager.shared`. Progress tracked via `@Query` on CompletedItemRecord.

Glass-styled phase cards with vibrant gradient accents per phase.

**Step 2: Commit**

```bash
git add LebaneseLearn/Views/Exercises/LessonsListView.swift
git commit -m "feat: rebuild lessons list with bundled content and phase tabs"
```

---

### Task 21: Rebuild Exercise Session View

**Files:**
- Modify: `LebaneseLearn/Views/Exercises/ExerciseSessionView.swift`

**Step 1: Rewrite to use ExerciseSet from bundled content**

Support all 5 exercise types from the content:
- Multiple choice (QuizQuestion)
- Fill-in-the-blank (FillBlankQuestion)
- Matching (MatchingPair)
- Sentence builder (SentenceBuilderItem)
- Dictation

On completion: save ExerciseResultRecord to SwiftData, award XP via XPEngine.

Liquid Glass answer cards, vibrant feedback colors (green for correct, coral for incorrect).

**Step 2: Commit**

```bash
git add LebaneseLearn/Views/Exercises/ExerciseSessionView.swift
git commit -m "feat: rebuild exercise session with all 5 exercise types"
```

---

### Task 22: Rebuild Review System

**Files:**
- Modify: `LebaneseLearn/Views/Review/ReviewDashboardView.swift`
- Modify: `LebaneseLearn/Views/Review/ReviewSessionView.swift`

**Step 1: Rewrite review to use local SwiftData SRS cards**

ReviewDashboard shows stats from `@Query` on SRSCardRecord. Due cards calculated locally. Seed button creates cards from phase vocab via SRSEngine.

ReviewSession: flashcard UI with rating buttons (1-5). Each rating calls `SRSEngine.processReview()`. Tap card to hear pronunciation via AudioService.

Glass-styled flashcards with morphing flip animation.

**Step 2: Commit**

```bash
git add LebaneseLearn/Views/Review/
git commit -m "feat: rebuild SRS review with local SwiftData and SM-2 engine"
```

---

### Task 23: Rebuild Leaderboard with CloudKit

**Files:**
- Modify: `LebaneseLearn/Views/Leaderboard/LeaderboardView.swift`
- Modify: `LebaneseLearn/Views/Leaderboard/PodiumView.swift`

**Step 1: Rewrite to use CloudKitService**

Fetch leaderboard from CloudKit public database. Show podium for top 3, list for rest. Current user highlighted. Pull-to-refresh. Glass-styled rank cards with vivid XP badges.

**Step 2: Commit**

```bash
git add LebaneseLearn/Views/Leaderboard/
git commit -m "feat: rebuild leaderboard with CloudKit"
```

---

### Task 24: Rebuild Profile View

**Files:**
- Modify: `LebaneseLearn/Views/Profile/ProfileView.swift`

**Step 1: Rewrite to use local UserProfile**

Show name, level, XP, streak, study goal from SwiftData UserProfile. Settings for:
- API key management (ElevenLabs, AI)
- Study goal adjustment
- Name editing

Glass-styled stat cards and settings sections.

**Step 2: Commit**

```bash
git add LebaneseLearn/Views/Profile/ProfileView.swift
git commit -m "feat: rebuild profile with SwiftData and API key settings"
```

---

### Task 25: Create AI Chat View

**Files:**
- Create: `LebaneseLearn/Views/AI/AIChatView.swift`
- Create: `LebaneseLearn/Views/AI/ChatBubble.swift`

**Step 1: Build conversation UI**

Chat interface with:
- Message list (user and AI bubbles)
- Text input with send button
- System prompt for Lebanese Arabic tutoring
- Conversation saved to AIConversationRecord
- Tap Arabic text in AI response to hear pronunciation

Glass-styled chat bubbles. User bubbles tinted brand coral. AI bubbles tinted electric blue.

**Step 2: Add AI tab or access point**

Either add as 6th tab or make accessible from Dashboard and Lessons views.

**Step 3: Commit**

```bash
git add LebaneseLearn/Views/AI/
git commit -m "feat: add AI conversation practice view"
```

---

### Task 26: Add Content Detail Views

**Files:**
- Create: `LebaneseLearn/Views/Lessons/VocabListView.swift`
- Create: `LebaneseLearn/Views/Lessons/DialogueView.swift`
- Create: `LebaneseLearn/Views/Lessons/GrammarDetailView.swift`
- Create: `LebaneseLearn/Views/Lessons/ScenarioPlayerView.swift`
- Create: `LebaneseLearn/Views/Lessons/VerbDetailView.swift`
- Create: `LebaneseLearn/Views/Lessons/CultureNoteView.swift`
- Create: `LebaneseLearn/Views/Lessons/ReadingView.swift`
- Create: `LebaneseLearn/Views/Lessons/ShadowingView.swift`

**Step 1: Create detail views for each content type**

Each view displays its content type with appropriate UI:
- **VocabListView** — scrollable word cards with tap-to-speak, category grouping
- **DialogueView** — conversation layout with speaker bubbles, play-all button
- **GrammarDetailView** — rule explanation with example table and interactive examples
- **ScenarioPlayerView** — branching dialogue with choice buttons
- **VerbDetailView** — conjugation table with tap-to-hear each form
- **CultureNoteView** — rich text with cultural items grid
- **ReadingView** — passage with vocab highlights and comprehension quiz
- **ShadowingView** — listen-and-repeat with step indicators

All use Liquid Glass cards and vibrant accent colors.

**Step 2: Commit**

```bash
git add LebaneseLearn/Views/Lessons/
git commit -m "feat: add content detail views for all 8 content types"
```

---

## Phase 8: Update Project Configuration

### Task 27: Update project.yml for New Files and Resources

**Files:**
- Modify: `project.yml`

**Step 1: Ensure project.yml includes Resources/Content as a resource folder**

Add the Content directory as a folder reference so JSON files are bundled:

```yaml
targets:
  LebaneseLearn:
    type: application
    platform: iOS
    sources:
      - LebaneseLearn
    resources:
      - path: LebaneseLearn/Resources/Content
        type: folder
    settings:
      base:
        INFOPLIST_FILE: LebaneseLearn/App/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.arabicisbeautiful.app
```

**Step 2: Regenerate Xcode project**

```bash
xcodegen generate
```

**Step 3: Commit**

```bash
git add project.yml LebaneseLearn.xcodeproj/
git commit -m "chore: update project config for new files and bundled content"
```

---

## Phase 9: Build & Verify

### Task 28: Build the Project

**Step 1: Build and fix any compilation errors**

```bash
xcodebuild -project LebaneseLearn.xcodeproj -scheme LebaneseLearn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build 2>&1 | tail -50
```

**Step 2: Fix any issues iteratively**

Common expected issues:
- Missing imports
- Type mismatches between old and new models
- Views referencing deleted services
- CodingKey mismatches with JSON field names

**Step 3: Commit fixes**

```bash
git add -A
git commit -m "fix: resolve compilation errors from architecture migration"
```

---

### Task 29: Tag Initial Release

**Step 1: Merge to dev, tag**

```bash
git checkout dev
git merge feature/local-first-architecture
git tag v0.1.0
git push origin dev --tags
```

Note: The feature branch name may vary based on the worktree branch. Adjust accordingly.

**Step 2: Open PR to main when ready for release**

```bash
gh pr create --base main --head dev --title "feat: local-first architecture with Liquid Glass UI" --body "$(cat <<'EOF'
## Summary
- Converted from server-dependent to local-first architecture
- All lesson content bundled as JSON (17 content types, 6 phases)
- SwiftData for user progress, SRS, XP, badges
- CloudKit public database for leaderboards
- ElevenLabs TTS with caching and system fallback
- Claude AI for conversation practice and grammar help
- iOS 26 Liquid Glass design language with vibrant colors
- Onboarding flow replaces auth

## Test plan
- [ ] Fresh install: onboarding flow completes, profile created
- [ ] All 6 phases load content correctly
- [ ] Exercise session works for all 5 types
- [ ] SRS card seeding and review cycle works
- [ ] XP awards and level-up triggers correctly
- [ ] ElevenLabs TTS plays Arabic audio (with API key configured)
- [ ] System TTS fallback works when offline
- [ ] AI chat sends/receives messages (with API key configured)
- [ ] CloudKit leaderboard fetches and updates
- [ ] Liquid Glass styling renders correctly on iOS 26

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Task Dependency Graph

```
Phase 1: [Task 1] → [Task 2]
Phase 2: [Task 3] (can parallel with Phase 3)
Phase 3: [Task 4] → [Task 5]
Phase 4: [Task 6] → [Task 7]
Phase 5: [Task 8, 9, 10, 11, 12, 13] (all parallel)
Phase 6: [Task 14] (depends on Phases 3-5)
Phase 7: [Task 15] → [Task 16-26] (16-26 mostly parallel after 15)
Phase 8: [Task 27] (depends on all above)
Phase 9: [Task 28] → [Task 29]
```

Tasks 8-13 (core services) are independent and can be built in parallel.
Tasks 16-26 (views) are mostly independent after Theme is updated.
