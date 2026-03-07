import Foundation

@Observable
final class ContentManager {
    static let shared = ContentManager()

    private var phasesCache: [Phase]?
    private var vocabCache: [Int: [VocabItem]] = [:]
    private var exercisesCache: [Int: [ExerciseSet]] = [:]
    private var dialoguesCache: [Int: [Dialogue]] = [:]
    private var grammarCache: [Int: [GrammarRule]] = [:]
    private var shadowingCache: [Int: [ShadowingItem]] = [:]
    private var scenariosCache: [Int: [ScenarioLesson]] = [:]
    private var verbsCache: [Int: [VerbConjugation]] = [:]
    private var cultureCache: [Int: [CultureNote]] = [:]

    func phases() -> [Phase] {
        if let cached = phasesCache { return cached }
        let loaded: [Phase] = load("phases")
        phasesCache = loaded
        return loaded
    }

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

    func readingPassages() -> [ReadingPassage] { load("reading") }
    func proverbs() -> [ProverbItem] { load("proverbs") }
    func roots() -> [ArabicRoot] { load("roots") }
    func minimalPairs() -> [MinimalPairSet] { load("minimal-pairs") }
    func msaComparisons() -> [MSAComparison] { load("msa-comparison") }
    func sounds() -> [SoundItem] { load("sounds") }
    func placementTest() -> [PlacementQuestion] { load("placement-test") }
    func journalPrompts() -> [JournalPrompt] { load("journal") }

    func allVocab() -> [VocabItem] {
        (1...6).flatMap { vocab(for: $0) }
    }

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
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("ContentManager: Failed to decode \(name).json — \(error)")
            return []
        }
    }
}
