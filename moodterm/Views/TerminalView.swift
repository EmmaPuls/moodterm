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
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    // TODO: TexEditor does not fill the height of the ScrollView
                    TextEditor(text: $viewModel.terminalOutput)
                        .padding()
                        .scrollContentBackground(.hidden)
                        .id(textEditorId)
                        .dynamicFont(.monospaced, factor: fontSizeFactor)
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .layoutPriority(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: viewModel.terminalOutput) {
                    withAnimation {
                        scrollViewProxy.scrollTo(textEditorId, anchor: .bottom)
                    }
                    textEditorId = UUID()  // Force refresh
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("textBackgroundColor"))
                .padding(.horizontal, 8)
                .cornerRadius(4)
            }

            TextField("Enter command", text: $userInput)
                .onSubmit {
                    viewModel.sendInput(userInput + "\n")
                    userInput = ""
                }
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .dynamicFont(.body, factor: fontSizeFactor)
        }
        .padding()
    }
}

#Preview {
    TerminalView(viewModel: TerminalViewModel(), fontSizeFactor: Binding<Double>.constant(2.5))
}
