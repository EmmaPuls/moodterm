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
    @Binding var fontSizeFactor: Double

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    TextEditor(text: $viewModel.terminalOutput)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id(textEditorId)
                        .dynamicFont(.monospaced, factor: fontSizeFactor)
                }
                .onChange(of: viewModel.terminalOutput) {
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
                .padding()
                .frame(maxWidth: .infinity)
                .dynamicFont(.body, factor: fontSizeFactor)
        }
        .padding()
    }
}

#Preview {
    TerminalView(viewModel: TerminalViewModel(), fontSizeFactor: Binding<Double>.constant(2.5))
}
