import Combine
import SwiftUI

class AppState: ObservableObject {
    @Published var tabs: [Tab] = MoodtermApp.loadTabs()
    @Published var selectedTab: UUID?
    @Published var fontSizeFactor: Double {
        didSet {
            debounceSaveFontSizeFactor()
        }
    }
    var cancellables = Set<AnyCancellable>()
    private var debounceTimer: AnyCancellable?

    init() {
        // Load the font size factor from UserDefaults
        if let savedFontSizeFactor = UserDefaults.standard.value(forKey: "fontSizeFactor") as? Double {
            self.fontSizeFactor = savedFontSizeFactor
        } else {
            self.fontSizeFactor = 1.0 // Default value
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
        do {
            // print the current directory from the first tab
            print("Saving directory: \(tabs.first?.currentDirectory ?? "")")
            let data = try JSONEncoder().encode(tabs)
            UserDefaults.standard.set(data, forKey: "savedTabs")
        } catch {
            print("Failed to save tabs: \(error)")
        }
    }

    private func debounceSaveFontSizeFactor() {
        debounceTimer?.cancel()
        debounceTimer = Just(fontSizeFactor)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { value in
                UserDefaults.standard.set(value, forKey: "fontSizeFactor")
            }
    }

    func removeTab(_ tab: Tab) {
        if let index = tabs.firstIndex(where: { $0.id == tab.id }) {
            tabs.remove(at: index)
            saveTabs(tabs)
        }
    }
}