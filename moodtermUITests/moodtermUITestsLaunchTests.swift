//
//  moodtermUITestsLaunchTests.swift
//  moodtermUITests
//
//  Created by Emma Puls on 27/10/2024.
//

import XCTest

final class moodtermUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)

        // Add a timeout to prevent hanging
        let exists = app.wait(for: .runningForeground, timeout: 10)
        XCTAssertTrue(exists, "App did not launch successfully")
    }
}
