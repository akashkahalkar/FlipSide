import SwiftUI

struct RollingDigitView: View {
    let value: Int
    var digits: [Int] {
        String(value).compactMap { Int(String($0)) }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<digits.count, id: \.self) {
                RollingDigit(digit: digits[$0])
            }
        }
    }
}

struct RollingDigit: View {
    let digit: Int
    let height: CGFloat = 40

    var body: some View {
        Color.clear
            .frame(width: 30, height: height)
            .overlay(alignment: .top) {
                VStack(spacing: 0) {
                    ForEach(0..<10) { num in
                        Text("\(num)")
                            .font(.custom("AvenirNextCondensed-Heavy", size: 30))
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
    RollingDigitView(value: 99)
}
