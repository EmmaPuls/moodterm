import SwiftUI
import Combine

/// Commands related to font size adjustments.
/// Allows the user to increase or decrease the font size of the app.
///
/// Keyboard shortcuts 
/// - **Cmd +** _increase font size_
/// - **Cmd -** _decrease font size_
struct FontSizeCommands: Commands {
    @Binding var fontSizeFactor: Double
    @State private var debounceTimer: AnyCancellable?
    @State private var accumulatedChange: Double = 0.0

    public init(fontSizeFactor: Binding<Double>) {
        self._fontSizeFactor = fontSizeFactor
    }

    var body: some Commands {
        CommandMenu("Font Size") {
            Button("Increase Font Size") {
                accumulateFontSizeChange(0.1)
            }
            .keyboardShortcut("+", modifiers: [.command])

            Button("Decrease Font Size") {
                accumulateFontSizeChange(-0.1)
            }
            .keyboardShortcut("-", modifiers: [.command])
        }
    }

    private func accumulateFontSizeChange(_ change: Double) {
        accumulatedChange += change
        debounceTimer?.cancel()
        debounceTimer = Just(())
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { _ in
                applyAccumulatedChange()
            }
    }

    private func applyAccumulatedChange() {
        fontSizeFactor = max(0.1, fontSizeFactor + accumulatedChange)
        accumulatedChange = 0.0
    }
}
