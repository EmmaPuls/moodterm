import SwiftUI

/// The `TabView` struct is responsible for displaying and managing multiple terminal tabs. It allows users to add, select, and close tabs.
///
/// - Properties:
///    - `tabs`: A binding to an array of `Tab` objects representing the open tabs.
///    - `selectedTab`: A binding to the UUID of the currently selected tab.
///    - `fontSizeFactor`: A binding to a `Double` that controls the font size factor for dynamic font scaling.
struct TabView: View {
    @ObservedObject var appState: AppState
    @Binding var fontSizeFactor: Double

    var body: some View {
        VStack {
            HStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach($appState.tabs) { $tab in
                            TabButton(
                                tab: $tab, selectedTab: $appState.selectedTab, closeTab: closeTab,
                                tabsCount: appState.tabs.count, fontSizeFactor: $fontSizeFactor)
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

            if let selectedTab = appState.selectedTab,
                let tab = appState.tabs.first(where: { $0.id == selectedTab })
            {
                TerminalView(viewModel: tab.viewModel, fontSizeFactor: $fontSizeFactor)
            }
        }
        .onAppear {
            if appState.tabs.isEmpty {
                addTab()
            }
            appState.selectedTab = appState.tabs.first?.id
        }
    }

    private func addTab() {
        let newTab = Tab(title: "New Tab", viewModel: TerminalViewModel())
        appState.tabs.append(newTab)
        appState.selectedTab = newTab.id
    }

    private func closeTab(_ tabId: UUID) {
        if let index = appState.tabs.firstIndex(where: { $0.id == tabId }) {
            withAnimation {
                appState.tabs.remove(at: index)
                if appState.selectedTab == tabId {
                    appState.selectedTab = appState.tabs.first?.id
                }
            }
        }
    }
}

/// Represents a tab button in the tab bar
private struct TabButton: View {
    @Binding var tab: Tab
    @Binding var selectedTab: UUID?
    var closeTab: (UUID) -> Void
    var tabsCount: Int
    @State private var isHovering = false
    @State private var isDeleting = false
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
                                withAnimation {
                                    isDeleting = true
                                }
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
        .opacity(isDeleting ? 0 : 1)
        .scaleEffect(isDeleting ? 0.5 : 1)
        .animation(.easeInOut(duration: 0.3), value: isDeleting)
        .transition(.slide)  // Add transition effect
    }
}

#Preview {
    let tab1 = Tab(title: "Tab 1", viewModel: TerminalViewModel())
    let tab2 = Tab(title: "Tab 2", viewModel: TerminalViewModel())
    TabView(
        appState: AppState(),
        fontSizeFactor: Binding<Double>.constant(1.2))
}
