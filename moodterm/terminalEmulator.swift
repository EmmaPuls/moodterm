//
//  terminalEmulator.swift
//  moodterm
//
//  Created by Emma Puls on 27/10/2024.
//
//  This code was inspired by:
//  - Alacritty:
//    - the defaultShellCommand from `alacritty_terminal/src/tty/unix.rs`
//

import Foundation
import Darwin

/// Sets the terminal to raw mode for the given file descriptor.
/// 
/// - Parameter fd: The file descriptor of the terminal.
/// - Returns: The original terminal attributes before setting raw mode.
/// 
/// This function modifies the terminal settings to disable canonical mode,
/// echoing, and other input processing features, allowing for raw input
/// handling.
func setRawMode(fd: Int32) -> termios {
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
func restoreTerminal(fd: Int32, termios: termios) {
    var termios = termios
    tcsetattr(fd, TCSANOW, &termios)
}

/// Retrieves the current user's information.
/// 
/// - Returns: A tuple containing the username, home directory, and shell path of the current user.
func getUserInfo() -> (username: String, homeDirectory: String, shellPath: String) {
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
func spawnShell() -> Int32 {
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
    process.currentDirectoryURL = URL(fileURLWithPath: homeDirectory) // Set the working directory to the user's home directory

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
func defaultShellCommand(shell: String, user: String) -> Process {
    let shellProcess = Process()
    shellProcess.executableURL = URL(fileURLWithPath: "/usr/bin/login")
    shellProcess.arguments = ["-flp", user, shell]
    return shellProcess
}