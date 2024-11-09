//
//  TabViewComponent.swift
//  moodterm
//
//  Created by Emma Puls on 28/10/2024.
//

import SwiftUI

/// Handles the tabs for each TerminalView
struct TabView: View {
    @Binding var tabs: [Tab]
    @Binding var selectedTab: UUID?

    var body: some View {
        VStack {
            HStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach($tabs) { $tab in
                            TabButton(
                                tab: $tab, selectedTab: $selectedTab, closeTab: closeTab,
                                tabsCount: tabs.count)
                        }

                        Button(action: addTab) {
                            Image(systemName: "plus")
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }.accessibilityLabel("Add new terminal tab")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)

            if let selectedTab = selectedTab, let tab = tabs.first(where: { $0.id == selectedTab })
            {
                TerminalView(viewModel: tab.viewModel)
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
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let tab1 = Tab(title: "Tab 1", viewModel: TerminalViewModel())
    let tab2 = Tab(title: "Tab 2", viewModel: TerminalViewModel())
    TabView(tabs: .constant([tab1, tab2]), selectedTab: .constant(tab1.id))
}
