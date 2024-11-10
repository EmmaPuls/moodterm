import SwiftUI

struct TerminalTextView: View {
    @Binding var text: String
    @Binding var fontSizeFactor: Double
    @State private var textEditorId = UUID()

    var body: some View {
        GeometryReader { reader in
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    ZStack {
                        // Spacer()
                        VStack {
                            Spacer()  // Pushes the text to the bottom
                            Text(text)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .dynamicFont(.monospaced, factor: fontSizeFactor)
                                .textSelection(.enabled)
                                .frame(
                                    maxWidth: .infinity, maxHeight: .infinity,
                                    alignment: .bottomLeading
                                )
                                .id(textEditorId)
                        }
                        .background(Color("textBackgroundColor"))
                        .cornerRadius(4)
                        .padding(.horizontal, 8)
                        .frame(minHeight: reader.size.height)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    }
                    .onChange(of: text) {
                        withAnimation {
                            scrollViewProxy.scrollTo(textEditorId, anchor: .bottom)
                        }
                        textEditorId = UUID()  // Force refresh

                    }.frame(alignment: .bottom)
                }
            }
        }
    }
}
