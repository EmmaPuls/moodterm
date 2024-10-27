//
//  ContentView.swift
//  moodterm
//
//  Created by Emma Puls on 27/10/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TerminalViewModel()
    @State private var userInput: String = ""

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    Text(viewModel.terminalOutput)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id("terminalOutput")
                }
                .onChange(of: viewModel.terminalOutput) {
                    withAnimation {
                        scrollViewProxy.scrollTo("terminalOutput", anchor: .bottom)
                    }
                }
            }
            TextField(
                "Enter command", text: $userInput
            )
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
    ContentView()
}
