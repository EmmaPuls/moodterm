import Combine
import SwiftUI

/// Manages the state of tabs in the application.
class TabStore: ObservableObject {
    @Published var tabs: [Tab] = []
    @Published var selectedTab: UUID?
    var cancellables = Set<AnyCancellable>()

    /// Get or create the application support directory.
    private var applicationSupportDirectory: URL {
        let directory = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!
        let moodtermDirectory = directory.appendingPathComponent("moodterm")

        // Ensure the moodterm directory exists
        if !FileManager.default.fileExists(atPath: moodtermDirectory.path) {
            do {
                try FileManager.default.createDirectory(
                    at: moodtermDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create moodterm directory: \(error)")
            }
        }

        return moodtermDirectory
    }

    private let tabDatabaseFileName: String = "tabs.json"

    private var databaseFileUrl: URL {
        applicationSupportDirectory.appendingPathComponent(tabDatabaseFileName)
    }

    /// Initialize the tab store from local data, or create a default tab if no data is found.
    init() {
        print("Database file path: \(databaseFileUrl.path)")  // Log the full path

        if let data = FileManager.default.contents(atPath: databaseFileUrl.path) {
            if let loadedTabs = try? loadTabs(from: data) {
                tabs = loadedTabs
            }
        } else if let bundledDatabaseUrl = Bundle.main.url(
            forResource: "tabs", withExtension: "json"),
            let data = FileManager.default.contents(atPath: bundledDatabaseUrl.path)
        {
            if let loadedTabs = try? loadTabs(from: data) {
                tabs = loadedTabs
            }
        } else {
            initializeDefaultTabs()
        }

        if tabs.isEmpty {
            print("Failed to load tabs or no tabs found")
            initializeDefaultTabs()
        }

        // Observe changes to the tabs and save them to disk
        $tabs
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.saveTabs(self.tabs)
            }
            .store(in: &cancellables)
    }

    /// Load tabs from a JSON file.
    private func loadTabs(from storeFileData: Data) throws -> [Tab] {
        let decoder = JSONDecoder()
        return try decoder.decode([Tab].self, from: storeFileData)
    }

    /// Initialize the tabs with a default value.
    private func initializeDefaultTabs() {
        tabs = [Tab(title: "Tab 1", viewModel: TerminalViewModel())]
    }

    /// Save the tabs to a JSON file.
    func saveTabs(_ tabs: [Tab]) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(tabs)
            if FileManager.default.fileExists(atPath: databaseFileUrl.path) {
                try FileManager.default.removeItem(at: databaseFileUrl)
            }
            try data.write(to: databaseFileUrl)
        } catch {
            print("Failed to save tabs: \(error)")
        }
    }
}
