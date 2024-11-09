import Combine
import Darwin
import Foundation

/// `TerminalManager` is responsible for managing terminal emulation.
/// 
/// Handles:
/// - setting the terminal to raw mode,
/// - spawning a shell process, and; 
/// - handling input/output between the terminal and the shell.
class TerminalManager {
    private var masterFd: Int32 = 0
    /// A `PassthroughSubject` that publishes terminal output as strings.
    let outputSubject = PassthroughSubject<String, Never>()

    /// Starts the terminal emulation process.
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

    /// Sends input to the shell process.
    func sendInput(_ input: String) {
        guard let data = input.data(using: .utf8) else { return }
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            write(masterFd, bytes.baseAddress, data.count)
        }
    }

    /// Sets the terminal to raw mode for the given file descriptor.
    ///
    /// - Parameter fd: The file descriptor of the terminal.
    /// - Returns: The original terminal attributes before setting raw mode.
    ///
    /// This function modifies the terminal settings to disable canonical mode,
    /// echoing, and other input processing features, allowing for raw input
    /// handling.
    private func setRawMode(fd: Int32) -> termios {
        var termios = termios()
        tcgetattr(fd, &termios)
        var raw = termios
        cfmakeraw(&raw)
        tcsetattr(fd, TCSANOW, &raw)
        return termios
    }

    /// Restores the terminal settings to a previous state.
    ///
    /// This function takes a file descriptor and a `termios` structure, and restores
    /// the terminal settings associated with the file descriptor to the state described
    /// by the `termios` structure.
    ///
    /// - Parameters:
    ///   - fd: The file descriptor representing the terminal.
    ///   - termios: A `termios` structure containing the terminal settings to be restored.
    private func restoreTerminal(fd: Int32, termios: termios) {
        var termios = termios
        tcsetattr(fd, TCSANOW, &termios)
    }

    /// Retrieves the current user's information.
    ///
    /// - Returns: A tuple containing the username, home directory, and shell path of the current user.
    private func getUserInfo() -> (username: String, homeDirectory: String, shellPath: String) {
        let uid = getuid()
        let passwd = getpwuid(uid)
        let username = String(cString: passwd!.pointee.pw_name)
        let homeDirectory = String(cString: passwd!.pointee.pw_dir)
        let shellPath = String(cString: passwd!.pointee.pw_shell)
        return (username, homeDirectory, shellPath)
    }

    /// Spawns a new shell process.
    ///
    /// This function creates and runs a new shell process, returning the process ID (PID) of the spawned shell.
    ///
    /// - Returns: The process ID (PID) of the spawned shell as an `Int32`.
    private func spawnShell() -> Int32 {
        var master: Int32 = 0
        var slave: Int32 = 0
        openpty(&master, &slave, nil, nil, nil)

        let (username, homeDirectory, shellPath) = getUserInfo()

        // Set environment variables
        setenv("HOME", homeDirectory, 1)
        setenv("USER", username, 1)
        setenv("LOGNAME", username, 1)
        setenv("SHELL", shellPath, 1)

        // Create the shell process
        let shellProcess = defaultShellCommand(shell: shellPath, user: username)

        // Set up the process
        let process = Process()
        process.executableURL = shellProcess.executableURL
        process.arguments = shellProcess.arguments
        process.environment = ProcessInfo.processInfo.environment
        process.standardInput = FileHandle(fileDescriptor: slave)
        process.standardOutput = FileHandle(fileDescriptor: slave)
        process.standardError = FileHandle(fileDescriptor: slave)
        process.currentDirectoryURL = URL(fileURLWithPath: homeDirectory)  // Set the working directory to the user's home directory

        do {
            try process.run()
        } catch {
            fatalError("Failed to start the shell: \(error)")
        }

        // Close the slave file descriptor in the parent process
        close(slave)

        return master
    }

    /// Creates and returns a `Process` configured to run a default shell command for a given user.
    ///
    /// - Parameters:
    ///   - shell: The shell to be used (e.g., "/bin/bash").
    ///   - user: The username for which the shell command is to be executed.
    /// - Returns: A `Process` object configured with the specified shell and user.
    private func defaultShellCommand(shell: String, user: String) -> Process {
        let shellProcess = Process()
        shellProcess.executableURL = URL(fileURLWithPath: "/usr/bin/login")
        shellProcess.arguments = ["-flp", user, shell]
        return shellProcess
    }
}
