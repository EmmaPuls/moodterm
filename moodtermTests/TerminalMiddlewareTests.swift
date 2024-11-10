import XCTest

@testable import moodterm

class TerminalMiddlewareTests: XCTestCase {

    func testFeedFromSession() {
        let middleware = TerminalMiddleware()
        let expectation = XCTestExpectation(description: "Data should be sent to outputToTerminal")

        let testData = "Test Data".data(using: .utf8)!

        let cancellable = middleware.outputToTerminal.sink { data in
            XCTAssertEqual(data, testData)
            expectation.fulfill()
        }

        middleware.feedFromSession(data: testData)

        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }

    func testFeedFromTerminal() {
        let middleware = TerminalMiddleware()
        let expectation = XCTestExpectation(description: "Data should be sent to outputToSession")

        let testData = "Test Data".data(using: .utf8)!

        let cancellable = middleware.outputToSession.sink { data in
            XCTAssertEqual(data, testData)
            expectation.fulfill()
        }

        middleware.feedFromTerminal(data: testData)

        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }

    func testClose() {
        let middleware = TerminalMiddleware()
        let expectation1 = XCTestExpectation(description: "outputToSession should complete")
        let expectation2 = XCTestExpectation(description: "outputToTerminal should complete")

        let cancellable1 = middleware.outputToSession.sink(
            receiveCompletion: { completion in
                if case .finished = completion {
                    expectation1.fulfill()
                }
            }, receiveValue: { _ in })

        let cancellable2 = middleware.outputToTerminal.sink(
            receiveCompletion: { completion in
                if case .finished = completion {
                    expectation2.fulfill()
                }
            }, receiveValue: { _ in })

        middleware.close()

        wait(for: [expectation1, expectation2], timeout: 1.0)
        cancellable1.cancel()
        cancellable2.cancel()
    }

    func testMiddlewareStackFeedFromSession() {
        let stack = TerminalMiddlewareStack()
        let middleware1 = TerminalMiddleware()
        let middleware2 = TerminalMiddleware()

        stack.push(middleware: middleware1)
        stack.push(middleware: middleware2)

        let expectation1 = XCTestExpectation(description: "Middleware1 should receive data")
        let expectation2 = XCTestExpectation(description: "Middleware2 should receive data")
        let expectation3 = XCTestExpectation(description: "Stack should receive data")

        let testData = "Test Data".data(using: .utf8)!

        let cancellable1 = middleware1.outputToTerminal.sink { data in
            XCTAssertEqual(data, testData)
            expectation1.fulfill()
        }

        let cancellable2 = middleware2.outputToTerminal.sink { data in
            XCTAssertEqual(data, testData)
            expectation2.fulfill()
        }

        let cancellable3 = stack.outputToTerminal.sink { data in
            XCTAssertEqual(data, testData)
            expectation3.fulfill()
        }

        stack.feedFromSession(data: testData)

        wait(for: [expectation1, expectation2, expectation3], timeout: 1.0)
        cancellable1.cancel()
        cancellable2.cancel()
        cancellable3.cancel()
    }

    func testMiddlewareStackFeedFromTerminal() {
        let stack = TerminalMiddlewareStack()
        let middleware1 = TerminalMiddleware()
        let middleware2 = TerminalMiddleware()

        stack.push(middleware: middleware1)
        stack.push(middleware: middleware2)

        let expectation1 = XCTestExpectation(description: "Middleware1 should receive data")
        let expectation2 = XCTestExpectation(description: "Middleware2 should receive data")
        let expectation3 = XCTestExpectation(description: "Stack should receive data")

        let testData = "Test Data".data(using: .utf8)!

        let cancellable1 = middleware1.outputToSession.sink { data in
            XCTAssertEqual(data, testData)
            expectation1.fulfill()
        }

        let cancellable2 = middleware2.outputToSession.sink { data in
            XCTAssertEqual(data, testData)
            expectation2.fulfill()
        }

        let cancellable3 = stack.outputToSession.sink { data in
            XCTAssertEqual(data, testData)
            expectation3.fulfill()
        }

        stack.feedFromTerminal(data: testData)

        wait(for: [expectation1, expectation2, expectation3], timeout: 1.0)
        cancellable1.cancel()
        cancellable2.cancel()
        cancellable3.cancel()
    }

    func testMiddlewareStackClose() {
        let stack = TerminalMiddlewareStack()
        let middleware1 = TerminalMiddleware()
        let middleware2 = TerminalMiddleware()

        stack.push(middleware: middleware1)
        stack.push(middleware: middleware2)

        let expectation1 = XCTestExpectation(description: "Middleware1 should complete")
        let expectation2 = XCTestExpectation(description: "Middleware2 should complete")
        let expectation3 = XCTestExpectation(description: "Stack should complete")

        let cancellable1 = middleware1.outputToSession.sink(
            receiveCompletion: { completion in
                if case .finished = completion {
                    expectation1.fulfill()
                }
            }, receiveValue: { _ in })

        let cancellable2 = middleware2.outputToSession.sink(
            receiveCompletion: { completion in
                if case .finished = completion {
                    expectation2.fulfill()
                }
            }, receiveValue: { _ in })

        let cancellable3 = stack.outputToSession.sink(
            receiveCompletion: { completion in
                if case .finished = completion {
                    expectation3.fulfill()
                }
            }, receiveValue: { _ in })

        stack.close()

        wait(for: [expectation1, expectation2, expectation3], timeout: 1.0)
        cancellable1.cancel()
        cancellable2.cancel()
        cancellable3.cancel()
    }
}
