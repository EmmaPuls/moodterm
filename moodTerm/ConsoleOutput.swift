//
//  ConsoleOutput.swift
//  moodTerm
//
//  Created by Emma Puls on 28/9/2024.
//

import SwiftUICore
import SwiftUI

struct ConsoleOutput: View {
    @Binding var commandOutputPairs: [(command: String, output: String)]
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(commandOutputPairs.indices, id: \.self) { index in
                        let pair = commandOutputPairs[index]
                        VStack(alignment: .leading, spacing: 5) {
                            Text("> \(pair.command)")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left
                                .textSelection(.enabled) // Enable text selection
                            Text("Output:\n\(pair.output)")
                                .font(.body)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left
                                .textSelection(.enabled) // Enable text selection
                        }.frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.gray, lineWidth: 1)
                            )
                    }
                }
                .padding([.top, .bottom])
            }
            .onChange(of: commandOutputPairs.count) { oldValue, newValue in
                    // Scroll to the latest output when a new command is added
                    if let lastIndex = commandOutputPairs.indices.last {
                        withAnimation {
                            proxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
