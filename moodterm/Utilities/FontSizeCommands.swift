import SwiftUI

/// Commands related to font size adjustments.
/// Allows the user to increase or decrease the font size of the app.
///
/// Keyboard shortcuts 
/// - **Cmd +** _increase font size_
/// - **Cmd -** _decrease font size_
struct FontSizeCommands: Commands {
    @Binding var fontSizeFactor: Double

    var body: some Commands {
        CommandMenu("Font Size") {
            Button("Increase Font Size") {
                fontSizeFactor += 0.1
            }
            .keyboardShortcut("+", modifiers: [.command])

            Button("Decrease Font Size") {
                fontSizeFactor = max(0.1, fontSizeFactor - 0.1)
            }
            .keyboardShortcut("-", modifiers: [.command])
        }
    }
}
