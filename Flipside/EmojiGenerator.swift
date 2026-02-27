struct EmojiGenerator {
    enum EmojiCategory: CaseIterable {
        case food, animals, fruits, sunSigns

        var range: ClosedRange<Int> {
            switch self {
            case .food:     return 0x1F950...0x1F96F
            case .animals:  return 0x1F980...0x1F9AE
            case .fruits:   return 0x1F345...0x1F353
            case .sunSigns: return 0x2648...0x2653
            }
        }

        var emojis: [String] {
            return range.compactMap { UnicodeScalar($0) }.map { String($0) }
        }
    }

    func getEmoji(maxCount: Int) -> [String] {
        let categories = EmojiCategory.allCases.filter { $0.range.count >= maxCount }
        guard let selectedCategory = categories.shuffled().first else {
            assertionFailure("no category with supported length found.")
            return []
        }
        return selectedCategory.emojis
    }
}

