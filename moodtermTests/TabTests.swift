import XCTest

@testable import moodterm

class TabTests: XCTestCase {

    func testTabInitialization() {
        let id = UUID()
        let title = "Test Tab"
        let viewModel = TerminalViewModel(id: UUID())  // Assuming TerminalViewModel has an initializer with id
        let tab = Tab(id: id, title: title, viewModel: viewModel)

        XCTAssertEqual(tab.id, id)
        XCTAssertEqual(tab.title, title)
        XCTAssertEqual(tab.viewModel.id, viewModel.id)
    }

    func testTabEncodingAndDecoding() throws {
        let id = UUID()
        let title = "Test Tab"
        let viewModel = TerminalViewModel(id: UUID())  // Assuming TerminalViewModel has an initializer with id
        let tab = Tab(id: id, title: title, viewModel: viewModel)

        let encoder = JSONEncoder()
        let data = try encoder.encode(tab)

        let decoder = JSONDecoder()
        let decodedTab = try decoder.decode(Tab.self, from: data)

        XCTAssertEqual(tab.id, decodedTab.id)
        XCTAssertEqual(tab.title, decodedTab.title)
        XCTAssertEqual(tab.currentDirectory, decodedTab.currentDirectory)
        XCTAssertEqual(tab.viewModel.id, decodedTab.viewModel.id)
    }

    func testTabEquality() {
        let id = UUID()
        let viewModelId = UUID()
        let viewModel1 = TerminalViewModel(id: viewModelId)  // Assuming TerminalViewModel has an initializer with id
        let viewModel2 = TerminalViewModel(id: viewModelId)  // Assuming TerminalViewModel has an initializer with id

        let tab1 = Tab(id: id, title: "Tab 1", viewModel: viewModel1)
        let tab2 = Tab(id: id, title: "Tab 1", viewModel: viewModel2)

        XCTAssertEqual(tab1, tab2)
    }

    func testTabInequality() {
        let id1 = UUID()
        let id2 = UUID()
        let viewModel1 = TerminalViewModel(id: UUID())  // Assuming TerminalViewModel has an initializer with id
        let viewModel2 = TerminalViewModel(id: UUID())  // Assuming TerminalViewModel has an initializer with id

        let tab1 = Tab(id: id1, title: "Tab 1", viewModel: viewModel1)
        let tab2 = Tab(id: id2, title: "Tab 2", viewModel: viewModel2)

        XCTAssertNotEqual(tab1, tab2)
    }

    func testTabCurrentDirectoryObservation() {
        let viewModel = TerminalViewModel(id: UUID())  // Assuming TerminalViewModel has an initializer with id
        let tab = Tab(title: "Test Tab", viewModel: viewModel)

        viewModel.currentDirectory = "/new/directory"
        XCTAssertEqual(tab.currentDirectory, "/new/directory")
    }
}
