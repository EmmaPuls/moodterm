import SwiftUI

/// A view that represents the terminal interface in the application.
/// This view is responsible for displaying the terminal content and handling user interactions.
///
/// - Parameters:
///    - viewModel: An observed object that manages the terminal's data and logic.
///    - fontSizeFactor: A binding that controls the font size factor for the terminal text and input field.
///
/// The view consists of a scrollable text editor that displays the terminal output and a text field for user input.
/// The text editor automatically scrolls to the bottom when new content is added.
/// The user input is sent to the view model when the return key is pressed.
struct TerminalView: View {
    @ObservedObject var viewModel: TerminalViewModel
    @State private var userInput: String = ""
    @State private var textEditorId = UUID()
    @Binding var fontSizeFactor: Double

    var body: some View {
        VStack {
            VStack {
                Spacer()  // Pushes the TextEditor to the bottom
                TerminalTextView(
                    text: $viewModel.terminalOutput, fontSizeFactor: $fontSizeFactor
                )
            }

            TextField("Enter command", text: $userInput)
                .onSubmit {
                    viewModel.sendInput(userInput + "\n")
                    userInput = ""
                }
                .dynamicFont(.body, factor: fontSizeFactor)
                .textFieldStyle(.plain)
                // Internal padding
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color("textBackgroundColor"))
                .cornerRadius(4)
                // External padding
                .padding(.horizontal, 8)

        }
        .padding(.bottom)
        .padding(.horizontal)
    }
}

#Preview {
    TerminalView(viewModel: TerminalViewModel(), fontSizeFactor: Binding<Double>.constant(1))
}
