// TODO: Write test for TerminalMiddleware
import Foundation
import Combine

class TerminalMiddleware {
    var outputToSession: PassthroughSubject<Data, Never> = PassthroughSubject()
    var outputToTerminal: PassthroughSubject<Data, Never> = PassthroughSubject()

    var outputToSessionPublisher: AnyPublisher<Data, Never> {
        return outputToSession.eraseToAnyPublisher()
    }

    var outputToTerminalPublisher: AnyPublisher<Data, Never> {
        return outputToTerminal.eraseToAnyPublisher()
    }

    func feedFromSession(data: Data) {
        outputToTerminal.send(data)
    }

    func feedFromTerminal(data: Data) {
        outputToSession.send(data)
    }

    func close() {
        outputToSession.send(completion: .finished)
        outputToTerminal.send(completion: .finished)
    }
}

class TerminalMiddlewareStack: TerminalMiddleware {
    private var middlewares: [TerminalMiddleware] = []

    func push(middleware: TerminalMiddleware) {
        middlewares.append(middleware)
    }

    override func feedFromSession(data: Data) {
        for middleware in middlewares {
            middleware.feedFromSession(data: data)
        }
        super.feedFromSession(data: data)
    }

    override func feedFromTerminal(data: Data) {
        for middleware in middlewares {
            middleware.feedFromTerminal(data: data)
        }
        super.feedFromTerminal(data: data)
    }

    override func close() {
        for middleware in middlewares {
            middleware.close()
        }
        super.close()
    }
}