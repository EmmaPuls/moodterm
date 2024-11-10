import Combine
import SwiftUI

@main
struct MoodtermApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .commands {
            FontSizeCommands(fontSizeFactor: $appState.fontSizeFactor)
        }
    }

    static func loadTabs() -> [Tab] {
        guard let data = UserDefaults.standard.data(forKey: "savedTabs") else {
            return [Tab(title: "Tab 1", viewModel: TerminalViewModel())]
        }
        do {
            // print the current directory from the first tab
            let tabs = try JSONDecoder().decode([Tab].self, from: data)
            print("Loaded directory: \(tabs.first?.currentDirectory ?? "")")
            return tabs
        } catch {
            print("Failed to load tabs: \(error)")
            return [Tab(title: "Tab 1", viewModel: TerminalViewModel())]
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(
            tabs: $appState.tabs, selectedTab: $appState.selectedTab,
            fontSizeFactor: $appState.fontSizeFactor
        )
        .onAppear {
            appState.selectedTab = appState.tabs.first?.id
            appState.observeTabChanges()
        }
        .onChange(of: appState.tabs) {
            appState.observeTabChanges()
        }
    }
}
