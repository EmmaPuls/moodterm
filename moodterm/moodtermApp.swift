//
//  moodtermApp.swift
//  moodterm
//
//  Created by Emma Puls on 27/10/2024.
//

import SwiftUI

/**
 The main application structure for the moodterm app.

 This struct conforms to the `App` protocol and serves as the entry point for the application.
 It manages the state of the tabs and the selected tab, and handles loading and saving of tabs
 using `UserDefaults`.

 - Properties:
    - tabs: An array of `Tab` objects representing the tabs in the application.
    - selectedTab: An optional UUID representing the currently selected tab.

 - Methods:
    - saveTabs(_:): Saves the given array of `Tab` objects to `UserDefaults`.
    - loadTabs(): Loads an array of `Tab` objects from `UserDefaults`, or returns a default tab if loading fails.
 */
@main
struct moodtermApp: App {
    @State private var tabs: [Tab] = loadTabs()
    @State private var selectedTab: UUID?

    var body: some Scene {
        WindowGroup {
            TabView(tabs: $tabs, selectedTab: $selectedTab)
                .onAppear {
                    selectedTab = tabs.first?.id
                }
                .onChange(of: tabs) { _ in
                    saveTabs(tabs)
                }
        }
    }

    private func saveTabs(_ tabs: [Tab]) {
        do {
            let data = try JSONEncoder().encode(tabs)
            UserDefaults.standard.set(data, forKey: "savedTabs")
        } catch {
            print("Failed to save tabs: \(error)")
        }
    }

    private static func loadTabs() -> [Tab] {
        guard let data = UserDefaults.standard.data(forKey: "savedTabs") else {
            return [Tab(title: "Tab 1", viewModel: TerminalViewModel())]
        }
        do {
            return try JSONDecoder().decode([Tab].self, from: data)
        } catch {
            print("Failed to load tabs: \(error)")
            return [Tab(title: "Tab 1", viewModel: TerminalViewModel())]
        }
    }
}