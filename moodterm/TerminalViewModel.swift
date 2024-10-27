//
//  TerminalViewModel.swift
//  moodterm
//
//  Created by Emma Puls on 27/10/2024.
//


import Foundation
import Combine

class TerminalViewModel: ObservableObject {
    @Published var terminalOutput: String = ""
    private var masterFd: Int32 = 0
    private var cancellables = Set<AnyCancellable>()
    private let outputSubject = PassthroughSubject<String, Never>()

    init() {
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

    func startTerminalEmulation() {
        let stdinFd = STDIN_FILENO

        // Set terminal to raw mode
        let originalTermios = setRawMode(fd: stdinFd)

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

    func sendInput(_ input: String) {
        guard let data = input.data(using: .utf8) else { return }
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            write(masterFd, bytes.baseAddress, data.count)
        }
    }
}