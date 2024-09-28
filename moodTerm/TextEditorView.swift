//
//  TextEditorView.swift
//  moodTerm
//
//  Created by Emma Puls on 28/9/2024.
//


//
//  TextEditorView.swift
//  moodTerm
//
//  Created by Emma Puls on 28/9/2024.
//

import SwiftUICore
import SwiftUI


struct TextEditorView: View {
    @State private var lastHandledCommand: String = ""
    @Binding public var command: String
    @Binding public var disabled: Bool
    public var onSend: () -> Void
    
    
    var body: some View {
        HStack {
            TextEditor(text: $command)
                .font(.monospaced(.body)())
                .foregroundStyle(.blue)
                .disabled(disabled)
                .onChange(of: command) { oldValue, newValue in
                    // If the last two characters were newlines
                    if (oldValue.last == "\n" && newValue.last == "\n") {
                        disabled = true
                        if lastHandledCommand != newValue {
                            // Remove the last newline
                            command.removeLast()
                            // Update the last handled command to prevent recursion
                            lastHandledCommand = command
                        } else {
                            // Trigger the talk function
                            onSend()
                        }
                        disabled = false
                    }
                }
            Button(LocalizedStringKey(stringLiteral: "Send"), action: onSend)
                .keyboardShortcut(.return, modifiers: [.command, .shift])
        }
    }
}

#Preview {
    ContentView()
}

