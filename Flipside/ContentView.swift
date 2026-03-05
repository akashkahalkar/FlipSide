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
    @State private var showGrid: Bool = false
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
                        .imageScale(.large)
                        .foregroundStyle(Color.white)
                }
                .buttonStyle(.glassProminent)
                .shadow(color: Color(secondaryColors[0]), radius: 5)
                .tint(Color(secondaryColors[0]))
                .frame(width: 60, height: 60)
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
                Text(viewModel.description)
                Button(viewModel.phase == .idle ? "Start" : "Restart") {
                    viewModel.startGame()
                }
                .buttonStyle(.glassProminent)
                .tint(Color(secondaryColors[0]))
                .shadow(color: Color(secondaryColors[0]), radius: 5)
                .disabled(viewModel.phase == .previewing || viewModel.phase == .interstitial)
            }
            .padding()
            .font(.custom("AvenirNextCondensed-Heavy", size: 30))
            .fontWeight(.black)

            if showGrid {
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
                    .transition(.move(edge: .bottom).combined(with: .opacity))

            }

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
        .onAppear {
            showGrid = viewModel.phase != .idle
        }
        .onChange(of: viewModel.phase, { _, newPhase in
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                showGrid = newPhase != .idle
            }
            if newPhase == .levelComplete {
                levelCompleteProgress = 0
                withAnimation(.linear(duration: 2.0)) {
                    levelCompleteProgress = 1
                }
            }
        })
        .onChange(of: viewModel.state.level) { oldLevel, newLevel in
            if newLevel > oldLevel {
                Haptics.levelUp()
            }
        }
        .onChange(of: viewModel.mismatchEventCount) { oldCount, newCount in
            if newCount > oldCount {
                Haptics.mismatchShort()
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            ThemeSettingsView(selectedThemeName: $selectedThemeName, showSettingsView: $isShowingSettings)
        }
    }
}

#Preview {
    ContentView()
}
