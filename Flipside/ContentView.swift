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
    @AppStorage("selectedTheme") private var selectedThemeName: String = FlatColors.Sunrise.rawValue
    @State private var isShowingSettings: Bool = false

    var body: some View {
        let theme = FlatColors(rawValue: selectedThemeName) ?? .Sunrise
        let primaryColors = theme.primaryColors
        let secondaryColors = theme.secondaryColors
        let tiles = viewModel.state.tiles
        let side = max(1, viewModel.gridSide)
        let columns = Array(repeating: GridItem(.flexible()), count: side)

        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button {
                    isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .imageScale(.medium)
                        .tint(Color(secondaryColors[1]))
                }
                .buttonStyle(.plain).frame(width: 40, height: 40)
            }


            HStack {
                HStack() {
                    Text("LEVEL")
                    RollingDigitView(value: viewModel.state.level)
                }
                .foregroundStyle(Color(secondaryColors[1]))
                Spacer()
                HStack() {
                    Text("MOVES")
                    RollingDigitView(value: viewModel.state.moves)
                }
                .foregroundStyle(Color(secondaryColors[1]))
            }
            .padding(.horizontal)
            .font(.custom("AvenirNextCondensed-Heavy", size: 30))
            .fontWeight(.black)
            .foregroundStyle(Color(red: 0.32, green: 0.35, blue: 0.4))

            VStack {
                if viewModel.phase == .previewing {
                    Text("Memorize...")
                        .font(.subheadline)
                        .foregroundStyle(Color(secondaryColors[1]))
                } else if viewModel.phase == .levelComplete {
                    Text("Level complete!")
                        .font(.subheadline)
                        .foregroundStyle(Color(secondaryColors[1]))
                } else if viewModel.phase == .idle {
                    Text("Tap Start to play")
                        .font(.subheadline)
                        .foregroundStyle(Color(secondaryColors[1]))
                }
                Button(viewModel.phase == .idle ? "Start" : "Restart") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        viewModel.startGame()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(secondaryColors[0]))
                .disabled(viewModel.phase == .previewing || viewModel.phase == .interstitial)
            }
            .padding()
            .font(.custom("AvenirNextCondensed-Heavy", size: 30))
            .fontWeight(.black)


            GeometryReader { proxy in
                let spacing: CGFloat = 12
                let gridSize = min(proxy.size.width, proxy.size.height)
                let totalSpacing = spacing * CGFloat(max(0, side - 1))
                let tileSize = max(12, (gridSize - totalSpacing) / CGFloat(side))

                ZStack {
                    if viewModel.phase != .levelComplete {
                        LazyVGrid(columns: columns, spacing: spacing) {
                            ForEach(tiles) { tile in
                                FlippingTile(
                                    tile: tile,
                                    size: tileSize,
                                    tileColors: [Color(secondaryColors[0]), Color(secondaryColors[1])]
                                ) {
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
            .padding(.top, 20)


            Spacer()

        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(primaryColors[0]), Color(primaryColors[1])],
                startPoint: .top,
                endPoint: .bottom
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
        .sheet(isPresented: $isShowingSettings) {
            ThemeSettingsView(selectedThemeName: $selectedThemeName, showSettingsView: $isShowingSettings)
        }
    }
}

#Preview {
    ContentView()
}
