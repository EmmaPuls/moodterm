import Foundation
import Combine

let OSCPrefix = Data([0x1b, 0x5d]) // ESC ]
let OSCSuffix = Data([0x07])       // BEL

class OSCProcessor: TerminalMiddleware {
    private var cwdReported = PassthroughSubject<String, Never>()

    var cwdReportedPublisher: AnyPublisher<String, Never> {
        return cwdReported.eraseToAnyPublisher()
    }

    override func feedFromSession(data: Data) {
        var startIndex = data.startIndex

        while let prefixRange = data.range(of: OSCPrefix, options: [], in: startIndex..<data.endIndex),
              let suffixRange = data.range(of: OSCSuffix, options: [], in: prefixRange.upperBound..<data.endIndex) {

            let params = data[prefixRange.upperBound..<suffixRange.lowerBound]
            let oscString = String(data: params, encoding: .utf8) ?? ""
            startIndex = suffixRange.upperBound

            let components = oscString.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
            guard let oscCodeString = components.first, let oscCode = Int(oscCodeString) else {
                continue
            }
            let oscParams = components.dropFirst().joined(separator: ";")

            if oscCode == 1337 {
                if oscParams.hasPrefix("CurrentDir=") {
                    var reportedCWD = String(oscParams.dropFirst("CurrentDir=".count))
                    if reportedCWD.hasPrefix("~") {
                        reportedCWD = FileManager.default.homeDirectoryForCurrentUser.path + reportedCWD.dropFirst()
                    }
                    cwdReported.send(reportedCWD)
                }
            } else {
                continue
            }
        }

        super.feedFromSession(data: data)
    }

    override func close() {
        cwdReported.send(completion: .finished)
        super.close()
    }
}