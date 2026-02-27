import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit: CGFloat = 4
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

struct FlippingTile: View {
    let tile: Tile
    let size: CGFloat
    let onTap: () -> Void

    private var isFlipped: Bool {
        tile.isFaceUp || tile.isMatched
    }

    var body: some View {
        let fontSize = max(14, size * 0.6)

        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.98, green: 0.93, blue: 0.89), Color(red: 0.95, green: 0.97, blue: 0.99)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Text(tile.content)
                        .foregroundColor(Color(red: 0.28, green: 0.32, blue: 0.38))
                        .lineLimit(1)
                        .font(.system(size: fontSize))
                )
                .opacity(isFlipped ? 1 : 0) // Visible only when flipped
                .frame(width: size, height: size)

            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.78, green: 0.86, blue: 0.98),
                            Color(red: 0.85, green: 0.95, blue: 0.90),
                            Color(red: 0.98, green: 0.87, blue: 0.90)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(isFlipped ? 0 : 1) // Hidden when flipped
                .frame(width: size, height: size)
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0) // Flip around the Y-axis
        )
        .modifier(ShakeEffect(amount: 8, shakesPerUnit: 4, animatableData: CGFloat(tile.shakeCount)))
        .animation(.easeOut(duration: 0.35), value: tile.shakeCount)
        .animation(.easeInOut(duration: 0.4), value: isFlipped)
        .onTapGesture {
            onTap()
        }
    }
}
