import Combine
import Foundation

/// `TerminalViewModel` communicates with the `TerminalManager` to manage the terminal state
/// and provides the terminal output to the view.
class TerminalViewModel: ObservableObject, Codable, Equatable {
    @Published var terminalOutput: String = ""
    private var terminalManager: TerminalManager
    private var cancellables = Set<AnyCancellable>()
    let id: UUID

    init(id: UUID = UUID(), terminalManager: TerminalManager = TerminalManager()) {
        self.id = id
        self.terminalManager = terminalManager
        setupOutputSubscription()
        terminalManager.startTerminalEmulation()
    }

    private func setupOutputSubscription() {
        terminalManager.outputSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                self?.terminalOutput += output
            }
            .store(in: &cancellables)
    }

    /// Sends input to the terminal.
    func sendInput(_ input: String) {
        terminalManager.sendInput(input)
    }

    enum CodingKeys: String, CodingKey {
        case id
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)

        // Initialize other properties
        terminalOutput = ""
        terminalManager = TerminalManager()
        cancellables = Set<AnyCancellable>()

        // Call methods after all properties are initialized
        setupOutputSubscription()
        terminalManager.startTerminalEmulation()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }

    static func == (lhs: TerminalViewModel, rhs: TerminalViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}
