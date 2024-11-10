import Combine
import XCTest

@testable import moodterm

class OSCMiddlewareTests: XCTestCase {
    var middleware: OSCMiddleware!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        middleware = OSCMiddleware()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        middleware = nil
        cancellables = nil
    }

    func testFeedFromSessionWithCurrentDir() {
        let expectation = XCTestExpectation(description: "Current directory should be reported")
        let testDir = "/Users/testuser"
        let oscMessage = "\u{1b}]1337;CurrentDir=\(testDir)\u{7}".data(using: .utf8)!

        middleware.cwdReported.sink { dir in
            XCTAssertEqual(dir, testDir, "The reported current directory should be \(testDir)")
            expectation.fulfill()
        }.store(in: &cancellables)

        middleware.feedFromSession(data: oscMessage)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFeedFromSessionWithHomeDir() {
        let expectation = XCTestExpectation(description: "Home directory should be expanded")
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        let testDir = "~/Documents"
        let expandedDir = homeDir + "/Documents"
        let oscMessage = "\u{1b}]1337;CurrentDir=\(testDir)\u{7}".data(using: .utf8)!

        middleware.cwdReported.sink { dir in
            XCTAssertEqual(
                dir, expandedDir,
                "The reported current directory should be expanded to \(expandedDir)")
            expectation.fulfill()
        }.store(in: &cancellables)

        middleware.feedFromSession(data: oscMessage)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFeedFromSessionWithInvalidOSC() {
        let expectation = XCTestExpectation(
            description: "Invalid OSC message should not report directory")
        expectation.isInverted = true
        let invalidOSCMessage = "\u{1b}]9999;InvalidMessage\u{7}".data(using: .utf8)!

        middleware.cwdReported.sink { _ in
            expectation.fulfill()
        }.store(in: &cancellables)

        middleware.feedFromSession(data: invalidOSCMessage)

        wait(for: [expectation], timeout: 1.0)
    }

    func testClose() {
        let expectation = XCTestExpectation(description: "cwdReported should complete")

        middleware.cwdReported.sink(
            receiveCompletion: { completion in
                if case .finished = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in }
        ).store(in: &cancellables)

        middleware.close()

        wait(for: [expectation], timeout: 1.0)
    }
}
