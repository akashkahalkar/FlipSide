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
            return range.compactMap { UnicodeScalar($0) }.map { String($0) }.shuffled()
        }
    }

    func getEmoji(maxCount: Int, excluding excluded: EmojiCategory?) -> (emojis: [String], category: EmojiCategory) {
        let categories = EmojiCategory.allCases.shuffled()
            .filter { $0.range.count >= maxCount }
            .filter { $0.self != excluded }

        guard let selectedCategory = categories.randomElement() else {
            assertionFailure("no category with supported length found.")
            return ([], .food)
        }
        return (selectedCategory.emojis, selectedCategory)
    }
}
