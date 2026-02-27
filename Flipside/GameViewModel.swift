import SwiftUI
import Observation

enum GamePhase: Equatable {
    case idle
    case interstitial
    case levelComplete
    case previewing
    case playing
}

@Observable
class GameViewModel {
    private(set) var state: GameState = GameState.defaultState
    private(set) var phase: GamePhase = .idle
    private var engine: GameEngine
    private let scheduler: Scheduler
    private var mismatchWork: Cancellable?
    private let previewDelayNanoseconds: UInt64
    private let interstitialDelayNanoseconds: UInt64
    private let levelCompleteDelayNanoseconds: UInt64
    private let endWaitNanoseconds: UInt64

    private let levelsPerGrid: Int
    private let mismatchDelay: TimeInterval

    init(
        emojiGenerator: EmojiGenerator = EmojiGenerator(),
        scheduler: Scheduler = DefaultScheduler(),
        mismatchDelay: TimeInterval = AnimationDelay.short,
        previewDelayNanoseconds: UInt64 = 3_000_000_000,
        interstitialDelayNanoseconds: UInt64 = 0,
        levelCompleteDelayNanoseconds: UInt64 = 2_000_000_000,
        endWaitNanoseconds: UInt64 = 2_000_000_000,
        levelsPerGrid: Int = 3
    ) {
        let safeLevelsPerGrid = max(1, levelsPerGrid)
        self.levelsPerGrid = safeLevelsPerGrid
        self.engine = GameEngine(
            emojiGenerator: emojiGenerator,
            pairsForLevel: { level in
                let side = 2 + 2 * ((max(1, level) - 1) / safeLevelsPerGrid)
                return (side * side) / 2
            }
        )
        self.scheduler = scheduler
        self.mismatchDelay = mismatchDelay
        self.previewDelayNanoseconds = previewDelayNanoseconds
        self.interstitialDelayNanoseconds = interstitialDelayNanoseconds
        self.levelCompleteDelayNanoseconds = levelCompleteDelayNanoseconds
        self.endWaitNanoseconds = endWaitNanoseconds
        self.state = engine.newGame(level: 1)
    }

    var gridSide: Int {
        let levelIndex = max(0, state.level - 1)
        return 2 + 2 * (levelIndex / levelsPerGrid)
    }

    func startGame() {
        startLevel(1, showInterstitial: false)
    }

    func restartLevel() {
        startLevel(state.level, showInterstitial: false)
    }

    private func startLevel(_ level: Int, showInterstitial: Bool) {
        mismatchWork?.cancel()
        mismatchWork = nil
        state = engine.newGame(level: level)
        state.isBusy = true

        if showInterstitial {
            phase = .interstitial
            revealAllTiles(false)
            Task { @MainActor [weak self] in
                guard let self else { return }
                try? await Task.sleep(nanoseconds: self.interstitialDelayNanoseconds)
                await self.startPreview()
            }
        } else {
            phase = .previewing
            revealAllTiles(true)
            Task { @MainActor [weak self] in
                guard let self else { return }
                try? await Task.sleep(nanoseconds: self.previewDelayNanoseconds)
            withAnimation(.easeOut(duration: 0.25)) {
                self.revealAllTiles(false)
            }
                self.state.isBusy = false
                self.phase = .playing
            }
        }
    }

    func onTileTap(_ index: Int) {
        if phase != .playing { return }
        switch engine.flip(at: index, state: &state) {
        case .ignored:
            return
        case .firstRevealed, .matchFound:
            return
        case .levelComplete:
            handleLevelComplete()
        case .mismatchFound(let indices):
            handleMismatch(indices: indices)
        }
    }

    private func handleMismatch(indices: (Int, Int)) {
        state.isBusy = true

        let first = indices.0
        let second = indices.1
        if state.tiles.indices.contains(first) {
            state.tiles[first].shakeCount += 1
        }
        if state.tiles.indices.contains(second) {
            state.tiles[second].shakeCount += 1
        }
        mismatchWork?.cancel()
        mismatchWork = scheduler.schedule(after: mismatchDelay) { [weak self] in
            self?.resolveMismatch(first: first, second: second)
        }
    }

    private func resolveMismatch(first: Int, second: Int) {
        if state.tiles.indices.contains(first) {
            state.tiles[first].isFaceUp = false
        }
        if state.tiles.indices.contains(second) {
            state.tiles[second].isFaceUp = false
        }
        state.isBusy = false
    }

    private func revealAllTiles(_ faceUp: Bool) {
        for index in state.tiles.indices {
            state.tiles[index].isFaceUp = faceUp
        }
    }

    private func startPreview() async {
        phase = .previewing
        revealAllTiles(true)
        try? await Task.sleep(nanoseconds: previewDelayNanoseconds)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            revealAllTiles(false)
        }
        state.isBusy = false
        phase = .playing
    }

    private func handleLevelComplete() {
        state.isBusy = true
        Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: self.endWaitNanoseconds)
            self.phase = .levelComplete
            try? await Task.sleep(nanoseconds: self.levelCompleteDelayNanoseconds)
            self.startLevel(self.state.level + 1, showInterstitial: false)
        }
    }
}
