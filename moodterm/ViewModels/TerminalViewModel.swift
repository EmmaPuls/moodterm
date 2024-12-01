import Combine
import Foundation

/// `TerminalViewModel` communicates with the `TerminalManager` to manage the terminal state
/// and provides the terminal output to the view.
class TerminalViewModel: ObservableObject, Codable, Equatable {
    @Published var terminalOutput: String = ""
    @Published var currentDirectory: String = ""
    private var terminalManager: TerminalManager
    private var middlewareStack: TerminalMiddlewareStack
    private var oscProcessor: OSCMiddleware
    var cancellables = Set<AnyCancellable>()
    let id: UUID

    init(id: UUID = UUID(), terminalManager: TerminalManager = TerminalManager(), initialDirectory: String? = nil) {
        self.id = id
        self.terminalManager = terminalManager
        self.middlewareStack = TerminalMiddlewareStack()
        self.oscProcessor = OSCMiddleware()

        // Set the initial directory if provided
        if let initialDirectory = initialDirectory {
            self.currentDirectory = initialDirectory
        }

        // Add OSCProcessor to middleware stack
        middlewareStack.push(middleware: oscProcessor)

        setupOutputSubscription()
        setupOSCProcessorSubscription()
        terminalManager.startTerminalEmulation(initialDirectory: initialDirectory)
    }

    private func setupOutputSubscription() {
        terminalManager.outputSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                self?.terminalOutput += output
                self?.middlewareStack.feedFromSession(data: Data(output.utf8))
            }
            .store(in: &cancellables)
    }

    private func setupOSCProcessorSubscription() {
        oscProcessor.cwdReportedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cwd in
                self?.currentDirectory = cwd
            }
            .store(in: &cancellables)
    }

    /// Sends input to the terminal.
    func sendInput(_ input: String) {
        terminalManager.sendInput(input)
        middlewareStack.feedFromTerminal(data: Data(input.utf8))
    }

    enum CodingKeys: String, CodingKey {
        case id, currentDirectory
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        currentDirectory = try container.decodeIfPresent(String.self, forKey: .currentDirectory) ?? ""

        // Initialize other properties
        terminalManager = TerminalManager()
        middlewareStack = TerminalMiddlewareStack()
        oscProcessor = OSCMiddleware()
        cancellables = Set<AnyCancellable>()

        // Add OSCProcessor to middleware stack
        middlewareStack.push(middleware: oscProcessor)

        // Call methods after all properties are initialized
        setupOutputSubscription()
        setupOSCProcessorSubscription()
        terminalManager.startTerminalEmulation(initialDirectory: currentDirectory)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(currentDirectory, forKey: .currentDirectory)
    }

    static func == (lhs: TerminalViewModel, rhs: TerminalViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}
