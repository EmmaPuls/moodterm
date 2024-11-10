import SwiftUI
import XCTest

@testable import moodterm

class FontSizeCommandsTests: XCTestCase {
    @ObservedObject private var fontSizeFactorWrapper = FontSizeFactorWrapper()

    func testIncreaseFontSize() {
        let commands = FontSizeCommands(fontSizeFactor: $fontSizeFactorWrapper.fontSizeFactor)
        commands.increaseFontSize()
        XCTAssertEqual(
            fontSizeFactorWrapper.fontSizeFactor, 1.1, "Font size factor should increase by 0.1")
    }

    func testDecreaseFontSize() {
        let commands = FontSizeCommands(fontSizeFactor: $fontSizeFactorWrapper.fontSizeFactor)
        commands.decreaseFontSize()
        XCTAssertEqual(
            fontSizeFactorWrapper.fontSizeFactor, 0.9, "Font size factor should decrease by 0.1")
    }

    func testDecreaseFontSizeMinimum() {
        fontSizeFactorWrapper.fontSizeFactor = 0.1
        let commands = FontSizeCommands(fontSizeFactor: $fontSizeFactorWrapper.fontSizeFactor)
        commands.decreaseFontSize()
        XCTAssertEqual(
            fontSizeFactorWrapper.fontSizeFactor, 0.1, "Font size factor should not go below 0.1")
    }
}

class FontSizeFactorWrapper: ObservableObject {
    @Published var fontSizeFactor: Double = 1.0
}
