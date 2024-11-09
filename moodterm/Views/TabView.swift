/// A SwiftUI view that handles the tabs for each TerminalView.
///
/// The `TabView` struct is responsible for displaying and managing multiple terminal tabs. It allows users to add, select, and close tabs. Each tab is represented by a `TabButton` view.
///
/// - Properties:
///    - `tabs`: A binding to an array of `Tab` objects representing the open tabs.
///    - `selectedTab`: A binding to the UUID of the currently selected tab.
///    - `fontSizeFactor`: A binding to a `Double` that controls the font size factor for dynamic font scaling.
///
/// - Nested Types:
///    - `TabButton`: A SwiftUI view representing a button for a single tab in the tab bar. It includes a text field for the tab title, a close button, and dynamic font scaling.

import SwiftUI

/// Handles the tabs for each TerminalView
struct TabView: View {
    @Binding var tabs: [Tab]
    @Binding var selectedTab: UUID?
    @Binding var fontSizeFactor: Double

    var body: some View {
        VStack {
            HStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach($tabs) { $tab in
                            TabButton(
                                tab: $tab, selectedTab: $selectedTab, closeTab: closeTab,
                                tabsCount: tabs.count, fontSizeFactor: $fontSizeFactor)
                        }

                        Button(action: addTab) {
                            Text("+")
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .cornerRadius(4)
                                .dynamicFont(.body, factor: fontSizeFactor)
                        }.accessibilityLabel("Add new terminal tab")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)

            if let selectedTab = selectedTab, let tab = tabs.first(where: { $0.id == selectedTab })
            {
                TerminalView(viewModel: tab.viewModel, fontSizeFactor: $fontSizeFactor)
            }
        }
        .onAppear {
            if tabs.isEmpty {
                addTab()
            }
            selectedTab = tabs.first?.id
        }
    }

    private func addTab() {
        let newTab = Tab(title: "New Tab", viewModel: TerminalViewModel())
        tabs.append(newTab)
        selectedTab = newTab.id
    }

    private func closeTab(_ id: UUID) {
        if tabs.count > 1 {
            tabs.removeAll { $0.id == id }
            if selectedTab == id {
                selectedTab = tabs.first?.id
            }
        }
    }
}

/// Represents a tab button in the tab bar
struct TabButton: View {
    @Binding var tab: Tab
    @Binding var selectedTab: UUID?
    var closeTab: (UUID) -> Void
    var tabsCount: Int
    @State private var isHovering = false
    @Binding var fontSizeFactor: Double

    var body: some View {
        HStack {
            TextField("Tab Title", text: $tab.title)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
                .overlay(
                    HStack {
                        Spacer()
                        if isHovering && tabsCount > 1 {
                            Button(action: {
                                closeTab(tab.id)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .padding(.trailing, 4)
                                    .shadow(color: .black, radius: 2, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel("Close tab")
                        }
                    }
                )
                .onTapGesture {
                    selectedTab = tab.id
                }
                .onHover { hovering in
                    isHovering = hovering
                }
                .accessibilityIdentifier("Tab_\(tab.id.uuidString)")
                .dynamicFont(.monospaced, factor: fontSizeFactor)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let tab1 = Tab(title: "Tab 1", viewModel: TerminalViewModel())
    let tab2 = Tab(title: "Tab 2", viewModel: TerminalViewModel())
    TabView(
        tabs: .constant([tab1, tab2]), selectedTab: .constant(tab1.id),
        fontSizeFactor: Binding<Double>.constant(1.2))
}
