import Foundation
struct Tile: Identifiable, Equatable {
    let id: UUID
    let content: String
    var isFaceUp: Bool
    var isMatched: Bool
    var shakeCount: Int
}

struct GameState: Equatable {
    var level: Int
    var moves: Int
    var tiles: [Tile]
    var firstSelectionIndex: Int?
    var isBusy: Bool

    static let defaultState: GameState = GameState(
        level: 0,
        moves: 0,
        tiles: [],
        firstSelectionIndex: nil,
        isBusy: false
    )
}

enum FlipResult {
    case ignored
    case firstRevealed
    case matchFound
    case mismatchFound(indices: (Int, Int))
    case levelComplete
}

struct GameEngine {
    private let emojiGenerator: EmojiGenerator
    private let pairsForLevel: (Int) -> Int

    init(
        emojiGenerator: EmojiGenerator,
        pairsForLevel: @escaping (Int) -> Int
    ) {
        self.emojiGenerator = emojiGenerator
        self.pairsForLevel = pairsForLevel
    }

    func newGame(level: Int) -> GameState {
        let pairs = max(1, pairsForLevel(level))
        let emojis = emojiGenerator.getEmoji(maxCount: pairs).prefix(pairs)
        let contents = (Array(emojis) + Array(emojis)).shuffled()
        let tiles = contents.map { content in
            Tile(id: UUID(), content: content, isFaceUp: false, isMatched: false, shakeCount: 0)
        }
        return GameState(
            level: level,
            moves: 0,
            tiles: tiles,
            firstSelectionIndex: nil,
            isBusy: false
        )
    }

    mutating func flip(at index: Int, state: inout GameState) -> FlipResult {
        guard state.tiles.indices.contains(index) else { return .ignored }
        if state.isBusy { return .ignored }
        if state.tiles[index].isMatched || state.tiles[index].isFaceUp { return .ignored }

        if let firstIndex = state.firstSelectionIndex {
            if firstIndex == index { return .ignored }

            state.tiles[index].isFaceUp = true
            state.moves += 1

            if state.tiles[firstIndex].content == state.tiles[index].content {
                state.tiles[firstIndex].isMatched = true
                state.tiles[index].isMatched = true
                state.firstSelectionIndex = nil

                if state.tiles.allSatisfy({ $0.isMatched }) {
                    return .levelComplete
                }
                return .matchFound
            } else {
                state.firstSelectionIndex = nil
                return .mismatchFound(indices: (firstIndex, index))
            }
        } else {
            state.tiles[index].isFaceUp = true
            state.firstSelectionIndex = index
            return .firstRevealed
        }
    }
}
