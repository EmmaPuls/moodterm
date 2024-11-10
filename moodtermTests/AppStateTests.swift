import Combine
import XCTest

@testable import moodterm

class AppStateTests: XCTestCase {
    var appState: AppState!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        // Reset UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "fontSizeFactor")
        UserDefaults.standard.removeObject(forKey: "savedTabs")

        appState = AppState()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        appState = nil
        cancellables = nil
    }

    func testInitialFontSizeFactor() {
        XCTAssertEqual(appState.fontSizeFactor, 1.0, "Initial font size factor should be 1.0")
    }

    func testLoadTabs() {
        let tabs = MoodtermApp.loadTabs()
        XCTAssertFalse(tabs.isEmpty, "Tabs should not be empty")
    }

    func testSaveTabs() {
        let tab = Tab(title: "Test Tab", viewModel: TerminalViewModel())
        appState.tabs = [tab]
        appState.saveTabs(appState.tabs)

        let savedTabs = MoodtermApp.loadTabs()
        XCTAssertEqual(savedTabs.count, 1, "There should be one saved tab")
        XCTAssertEqual(
            savedTabs.first?.title, "Test Tab", "The saved tab title should be 'Test Tab'")
    }
}
