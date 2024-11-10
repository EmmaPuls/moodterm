import Combine
import SwiftUI

class AppState: ObservableObject {
    @Published var tabs: [Tab] = MoodtermApp.loadTabs()
    @Published var selectedTab: UUID?
    @Published var fontSizeFactor: Double {
        didSet {
            UserDefaults.standard.set(fontSizeFactor, forKey: "fontSizeFactor")
        }
    }
    var cancellables = Set<AnyCancellable>()

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