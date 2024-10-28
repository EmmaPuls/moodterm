//
//  ContentView.swift
//  moodterm
//
//  Created by Emma Puls on 27/10/2024.
//

import SwiftUI

/// A view that represents the terminal interface in the application.
/// This view is responsible for displaying the terminal content and handling user interactions.
struct TerminalView: View {
    @ObservedObject var viewModel: TerminalViewModel
    @State private var userInput: String = ""
    @State private var textEditorId = UUID()

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    TextEditor(text: $viewModel.terminalOutput)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id(textEditorId)
                }
                .onChange(of: viewModel.terminalOutput) { _ in
                    withAnimation {
                        scrollViewProxy.scrollTo(textEditorId, anchor: .bottom)
                    }
                    textEditorId = UUID() // Force refresh
                }
            }
            TextField("Enter command", text: $userInput)
                .onSubmit {
                    viewModel.sendInput(userInput + "\n")
                    userInput = ""
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

#Preview {
    TerminalView(viewModel: TerminalViewModel())
}