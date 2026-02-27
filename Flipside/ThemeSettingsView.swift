import SwiftUI

struct ThemeSettingsView: View {
    @Binding var selectedThemeName: String

    var body: some View {
        NavigationStack {
            List {
                ForEach(FlatColors.allCases, id: \.rawValue) { theme in
                    let isSelected = selectedThemeName == theme.rawValue
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color(theme.primaryColors[0]), Color(theme.secondaryColors[0])],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 32)
                        Text(theme.rawValue)
                            .font(.headline)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedThemeName = theme.rawValue
                    }
                }
            }
            .navigationTitle("Themes")
        }
    }
}

#Preview {
    ThemeSettingsView(selectedThemeName: .constant(FlatColors.Sunrise.rawValue))
}
