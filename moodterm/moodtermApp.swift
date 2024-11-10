import Combine
import SwiftUI

@main
struct MoodtermApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            TabView(
                tabs: $appState.tabs, selectedTab: $appState.selectedTab,
                fontSizeFactor: $appState.fontSizeFactor
            )
            .onAppear {
                appState.selectedTab = appState.tabs.first?.id
                appState.observeTabChanges()
            }
            .onChange(of: appState.tabs) { _ in
                appState.observeTabChanges()
            }
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

class AppState: ObservableObject {
    @Published var tabs: [Tab] = MoodtermApp.loadTabs()
    @Published var selectedTab: UUID?
    @Published var fontSizeFactor: Double = 1.0
    var cancellables = Set<AnyCancellable>()

    func observeTabChanges() {
        cancellables.removeAll()
        for tab in tabs {
            tab.$currentDirectory
                // Debounce to make sure that the tabs are saved after the currentDirectory has been updated
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.saveTabs(self?.tabs ?? [])
                }
                .store(in: &cancellables)
        }
    }

    func saveTabs(_ tabs: [Tab]) {
        do {
            // print the current directory from the first tab
            print("Saving directory: \(tabs.first?.currentDirectory ?? "")")
            let data = try JSONEncoder().encode(tabs)
            UserDefaults.standard.set(data, forKey: "savedTabs")
        } catch {
            print("Failed to save tabs: \(error)")
        }
    }
}