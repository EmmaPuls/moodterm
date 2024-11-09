import SwiftUI

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