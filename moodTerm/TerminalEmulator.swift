//
//  TerminalEmulator.swift
//  moodTerm
//
//  Created by Emma Puls on 28/9/2024.
//


import SwiftUI


struct TerminalEmulator: View {
    // Comand Line State management
    @State private var currentDirectory: String = NSHomeDirectory()
    @State private var environmentVariables: [String: String] = ProcessInfo.processInfo.environment

    
    // User Input management
    @State private var command: String = ""
    @State private var output: String = ""
    @State private var commandOutputPairs: [(command: String, output: String)] = []
    @State private var isTextEditorDisabled: Bool = false
    
    func executeCommand() {
        if command.starts(with: "cd ") {
            handleCdCommand()
        } else if command.starts(with: "export ") {
            handleExportCommand()
        } else {
            runExternalCommand()
        }
        command = ""
    }
    
    func handleCdCommand() {
        let newPath = command.dropFirst(3).trimmingCharacters(in: .whitespacesAndNewlines)
        let expandedPath = NSString(string: newPath).expandingTildeInPath
        let fileManager = FileManager.default
        if fileManager.changeCurrentDirectoryPath(expandedPath) {
            currentDirectory = expandedPath
            commandOutputPairs.append((command: command, output: "Changed directory to \(expandedPath)"))
        } else {
            commandOutputPairs.append((command: command, output: "Directory not found: \(expandedPath)"))
        }
    }
    
    func handleExportCommand() {
        let exportCommand = command.dropFirst(7).trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = exportCommand.split(separator: "=", maxSplits: 1).map { String($0) }
        if parts.count == 2 {
            let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
            environmentVariables[key] = value
            commandOutputPairs.append((command: command, output: "Set (key) to (value)"))
        } else {
            commandOutputPairs.append((command: command, output: "Invalid export command"))
        }
    }

    func runExternalCommand() {
        commandOutputPairs.append((command: command, output: ""))
        isTextEditorDisabled = true
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]
        task.currentDirectoryPath = currentDirectory
        task.environment = environmentVariables
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let fileHandle = pipe.fileHandleForReading
        fileHandle.readabilityHandler = { handle in
            let data = handle.availableData
            if let outputString = String(data: data, encoding: .utf8), !outputString.isEmpty {
                DispatchQueue.main.async {
                    commandOutputPairs[commandOutputPairs.count - 1].output.append(outputString)
                }
            }
        }
        task.launch()
        task.terminationHandler = { _ in
            DispatchQueue.main.async {
                isTextEditorDisabled = false
            }
            fileHandle.readabilityHandler = nil
        }
    }
    
    var body: some View {
        VStack {
            ConsoleOutput(commandOutputPairs: $commandOutputPairs).frame(maxHeight: .infinity)
            Spacer()
            TextEditorView(command: $command, disabled: $isTextEditorDisabled, onSend: executeCommand).frame(maxHeight:100)
        }.padding()
    }
}
