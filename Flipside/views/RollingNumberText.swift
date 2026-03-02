import SwiftUI

struct RollingDigitView: View {
    let value: Int
    var spacing: CGFloat = -2
    var digits: [Int] {
        String(value).compactMap { Int(String($0)) }
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<digits.count, id: \.self) {
                RollingDigit(digit: digits[$0])
            }
        }
    }
}

struct RollingDigit: View {
    let digit: Int
    let height: CGFloat = 40
    let width: CGFloat = 24

    var body: some View {
        Color.clear
            .frame(width: width, height: height)
            .overlay(alignment: .top) {
                VStack(spacing: 0) {
                    ForEach(0..<10) { num in
                        Text("\(num)")
                            .font(.custom("AvenirNextCondensed-Heavy", size: 30))
                            .monospacedDigit()
                            .frame(height: height)

                    }
                }
                .offset(y: -CGFloat(digit) * height)
            }
            .clipped()
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: digit)
    }
}

#Preview {
    RollingDigitView(value: 999)
}
