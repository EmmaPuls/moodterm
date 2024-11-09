import SwiftUI
import XCTest

@testable import moodterm

final class moodtermUITests: XCTestCase {
    let app = XCUIApplication()

    // MARK: - Setup and Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the app that they test. Do this in setup to ensure that it the app launches for each test method.
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                app.launch()
            }
        }
    }

    func testTabAddAndRemove() {
        // Get all the app buttons
        let buttons = app.buttons.allElementsBoundByIndex
        XCTAssertTrue(buttons.count > 0, "There should be at least one button")

        // Count the number of tabs
        let initialTabCount = app.textFields.containing(
            NSPredicate(format: "identifier BEGINSWITH 'Tab_'")
        ).count
        XCTAssertTrue(initialTabCount > 0, "There should be at least one tab")

        // Find the button with the accessibility label "Add new terminal tab"
        let plusButton = app.buttons["Add new terminal tab"]
        XCTAssertTrue(plusButton.exists, "Add tab button should exist")
        plusButton.tap()

        // There should be one more tab now
        let newTabCount = app.textFields.containing(
            NSPredicate(format: "identifier BEGINSWITH 'Tab_'")
        ).count
        XCTAssertEqual(newTabCount, initialTabCount + 1, "There should be one more tab")

        // Find the button with the accessibility label "Close tab"
        let closeButton = app.buttons["Close tab"]
        XCTAssertTrue(closeButton.exists, "Close tab button should exist")
        closeButton.tap()

        // There should be one less tab now
        let finalTabCount = app.textFields.containing(
            NSPredicate(format: "identifier BEGINSWITH 'Tab_'")
        ).count
        XCTAssertEqual(finalTabCount, initialTabCount, "There should be one less tab")
    }
}
