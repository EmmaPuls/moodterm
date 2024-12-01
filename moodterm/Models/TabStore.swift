import Combine
import SwiftUI

/// A class manages the state of tabs in the application.
class TabStore: ObservableObject {
    @Published var tabs: [Tab] = []
    @Published var selectedTab: UUID?
    var cancellables = Set<AnyCancellable>()

    private var applicationSupportDirectory: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let moodtermDirectory = directory.appendingPathComponent("moodterm")
        
        // Ensure the moodterm directory exists
        if !FileManager.default.fileExists(atPath: moodtermDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: moodtermDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create moodterm directory: \(error)")
            }
        }
        
        return moodtermDirectory
    }

    private var filename = "tabs.json"

    private var databaseFileUrl: URL {
        applicationSupportDirectory.appendingPathComponent(filename)
    }

    private func loadTabs(from storeFileData: Data) -> [Tab] {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Tab].self, from: storeFileData)
        } catch {
            print(error)
            return [Tab(title: "Tab 1", viewModel: TerminalViewModel())]
        }
    }

    init() {
        print("Database file path: \(databaseFileUrl.path)") // Log the full path

        if let data = FileManager.default.contents(atPath: databaseFileUrl.path) {
            tabs = loadTabs(from: data)
        } else {
            if let bundledDatabaseUrl = Bundle.main.url(forResource: "tabs", withExtension: "json") {
                if let data = FileManager.default.contents(atPath: bundledDatabaseUrl.path) {
                    tabs = loadTabs(from: data)
                }
            } else {
                tabs = [Tab(title: "Tab 1", viewModel: TerminalViewModel())]
            }
        }
    }

    func observeTabChanges() {
        cancellables.removeAll()
        for tab in tabs {
            tab.$currentDirectory
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.saveTabs(self?.tabs ?? [])
                }
                .store(in: &cancellables)
        }
    }

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