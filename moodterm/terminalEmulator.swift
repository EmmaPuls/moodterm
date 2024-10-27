//
//  terminalEmulator.swift
//  moodterm
//
//  Created by Emma Puls on 27/10/2024.
//

import Foundation

func setRawMode(fd: Int32) -> termios {
    var termios = termios()
    tcgetattr(fd, &termios)
    var raw = termios
    cfmakeraw(&raw)
    tcsetattr(fd, TCSANOW, &raw)
    return termios
}

func restoreTerminal(fd: Int32, termios: termios) {
    var termios = termios
    tcsetattr(fd, TCSANOW, &termios)
}

func spawnShell() -> Int32 {
    var master: Int32 = 0
    var slave: Int32 = 0
    openpty(&master, &slave, nil, nil, nil)
    
    var pid: pid_t = 0
    let fileActions = UnsafeMutablePointer<posix_spawn_file_actions_t?>.allocate(capacity: 1)
    posix_spawn_file_actions_init(fileActions)
    posix_spawn_file_actions_addclose(fileActions, master)
    posix_spawn_file_actions_adddup2(fileActions, slave, STDIN_FILENO)
    posix_spawn_file_actions_adddup2(fileActions, slave, STDOUT_FILENO)
    posix_spawn_file_actions_adddup2(fileActions, slave, STDERR_FILENO)
    posix_spawn_file_actions_addclose(fileActions, slave)

    let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/sh"
    let argv: [UnsafeMutablePointer<CChar>?] = [strdup(shell), nil]
    let envp: [UnsafeMutablePointer<CChar>?] = [nil]

    let status = posix_spawn(&pid, shell, fileActions, nil, argv, envp)
    posix_spawn_file_actions_destroy(fileActions)

    if status == 0 {
        // Parent process
        close(slave)
        return master
    } else {
        fatalError("posix_spawn failed")
    }
}

func startTerminalEmulation() {
    let stdinFd = STDIN_FILENO

    // Set terminal to raw mode
    let originalTermios = setRawMode(fd: stdinFd)

    // Spawn the shell
    let masterFd = spawnShell()

    // Create a thread to read from the shell and write to stdout
    DispatchQueue.global().async {
        var buffer = [UInt8](repeating: 0, count: 1024)
        while true {
            let n = read(masterFd, &buffer, buffer.count)
            if n <= 0 {
                break
            }
            FileHandle.standardOutput.write(Data(buffer[0..<n]))
        }
    }

    // Read from stdin and write to the shell
    var buffer = [UInt8](repeating: 0, count: 1024)
    while true {
        let n = read(stdinFd, &buffer, buffer.count)
        if n <= 0 {
            break
        }
        write(masterFd, buffer, n)
    }

    // Restore terminal settings
    restoreTerminal(fd: stdinFd, termios: originalTermios)
}
