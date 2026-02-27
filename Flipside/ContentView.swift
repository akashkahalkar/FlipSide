//
//  ContentView.swift
//  Flipside
//
//  Created by Akash on 20/02/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()
    @State private var levelCompleteProgress: Double = 0

    var body: some View {
        let tiles = viewModel.state.tiles
        let side = max(1, viewModel.gridSide)
        let columns = Array(repeating: GridItem(.flexible()), count: side)

        VStack(spacing: 16) {
            HStack {
                Text("Level \(viewModel.state.level)")
                Spacer()
                Text("Moves \(viewModel.state.moves)")
            }
            .font(.headline)
            .foregroundStyle(Color(red: 0.32, green: 0.35, blue: 0.4))

            HStack {
                Button(viewModel.phase == .idle ? "Start" : "Restart") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        viewModel.startGame()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.68, green: 0.80, blue: 0.95))
                .disabled(viewModel.phase == .previewing || viewModel.phase == .interstitial)

                if viewModel.phase == .previewing {
                    Text("Memorize...")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.45, green: 0.5, blue: 0.56))
                } else if viewModel.phase == .levelComplete {
                    Text("Level complete!")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.45, green: 0.5, blue: 0.56))
                } else if viewModel.phase == .idle {
                    Text("Tap Start to play")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.45, green: 0.5, blue: 0.56))
                }
            }

            GeometryReader { proxy in
                let spacing: CGFloat = 12
                let gridSize = min(proxy.size.width, proxy.size.height)
                let totalSpacing = spacing * CGFloat(max(0, side - 1))
                let tileSize = max(12, (gridSize - totalSpacing) / CGFloat(side))

                ZStack {
                    if viewModel.phase != .levelComplete {
                        LazyVGrid(columns: columns, spacing: spacing) {
                            ForEach(tiles) { tile in
                                FlippingTile(tile: tile, size: tileSize) {
                                    guard let index = tiles.firstIndex(of: tile) else {
                                        return
                                    }
                                    viewModel.onTileTap(index)
                                }
                            }
                        }
                        .frame(width: gridSize, height: gridSize, alignment: .center)
                    }

                    if viewModel.phase == .interstitial {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.35))
                            .frame(width: gridSize, height: gridSize)
                            .overlay(
                                Text("Level \(viewModel.state.level)")
                                    .font(.title.bold())
                                    .foregroundStyle(.white)
                            )
                    } else if viewModel.phase == .levelComplete {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.55))
                            .frame(width: gridSize, height: gridSize)
                            .overlay(
                                VStack(spacing: 12) {
                                    Text("Level \(viewModel.state.level) Complete")
                                        .font(.title.bold())
                                        .foregroundStyle(.white)
                                    ProgressView(value: levelCompleteProgress)
                                        .tint(.white)
                                        .frame(width: gridSize * 0.6)
                                }
                            )
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.99),
                    Color(red: 0.96, green: 0.93, blue: 0.98),
                    Color(red: 0.98, green: 0.95, blue: 0.93)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onChange(of: viewModel.phase, { _, newPhase in
            if newPhase == .levelComplete {
                levelCompleteProgress = 0
                withAnimation(.linear(duration: 2.0)) {
                    levelCompleteProgress = 1
                }
            }
        })
    }
}

#Preview {
    ContentView()
}
