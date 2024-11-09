//
//  TerminalViewModel.swift
//  moodterm
//
//  Created by Emma Puls on 27/10/2024.
//

import Combine
import Foundation

/// Is responsible for managing the state and behavior of the terminal.
class TerminalViewModel: ObservableObject, Codable, Equatable {
    @Published var terminalOutput: String = ""
    private var masterFd: Int32 = 0
    private var cancellables = Set<AnyCancellable>()
    private let outputSubject = PassthroughSubject<String, Never>()
    let id: UUID

    init(
        id: UUID = UUID()
    ) {
        self.id = id
        startTerminalEmulation()
        setupOutputSubscription()
    }

    private func setupOutputSubscription() {
        outputSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                self?.terminalOutput += output
            }
            .store(in: &cancellables)
    }

    
    /// Starts the terminal emulation process.
    ///
    /// This function initializes and begins the emulation of a terminal session.
    /// It sets up necessary configurations and resources required for the terminal
    /// to function properly.
    /// 
    /// Sets a terminal to raw mode, spawns a shell, and creates a thread to read
    /// from the shell and update the terminal output.
    /// 
    /// Once the terminal emulation is stopped, the terminal settings are restored
    func startTerminalEmulation() {
        let stdinFd = STDIN_FILENO

        // Set terminal to raw mode
        let originalTermios = setRawMode(fd: stdinFd)

        // Set TERM environment variable
        setenv("TERM", "xterm-256color", 1)

        // Spawn the shell
        masterFd = spawnShell()

        // Create a thread to read from the shell and update terminalOutput
        DispatchQueue.global().async { [weak self] in
            var buffer = [UInt8](repeating: 0, count: 1024)
            while true {
                let n = read(self?.masterFd ?? -1, &buffer, buffer.count)
                if n <= 0 {
                    break
                }
                let output = String(bytes: buffer[0..<n], encoding: .utf8) ?? ""
                self?.outputSubject.send(output)
            }
        }

        // Restore terminal settings
        restoreTerminal(fd: stdinFd, termios: originalTermios)
    }


    /// Sends input to the terminal.
    func sendInput(_ input: String) {
        guard let data = input.data(using: .utf8) else { return }
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            write(masterFd, bytes.baseAddress, data.count)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)

        // Initialize other properties
        terminalOutput = ""
        masterFd = 0
        cancellables = Set<AnyCancellable>()

        // Call methods after all properties are initialized
        startTerminalEmulation()
        setupOutputSubscription()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }

    static func == (lhs: TerminalViewModel, rhs: TerminalViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}
