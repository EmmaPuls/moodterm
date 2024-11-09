import Combine
import Foundation

///  Defines the `Tab` class, which represents a terminal tab.
class Tab: Identifiable, Codable, Equatable, ObservableObject {
    let id: UUID
    /// The title of the tab.
    var title: String
    /// The current directory of the tab.
    @Published var currentDirectory: String = ""
    var viewModel: TerminalViewModel

    init(id: UUID = UUID(), title: String, viewModel: TerminalViewModel) {
        self.id = id
        self.title = title
        self.viewModel = viewModel

        // Observe the currentDirectory of the viewModel
        viewModel.$currentDirectory
            .sink { [weak self] cwd in
                self?.currentDirectory = cwd
            }
            .store(in: &viewModel.cancellables)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, viewModel, currentDirectory
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        currentDirectory = try container.decodeIfPresent(String.self, forKey: .currentDirectory) ?? ""
        viewModel = try container.decode(TerminalViewModel.self, forKey: .viewModel)

        // Initialize the viewModel with the current directory
        viewModel = TerminalViewModel(id: id, terminalManager: TerminalManager(), initialDirectory: currentDirectory)

        // Observe the currentDirectory of the viewModel
        viewModel.$currentDirectory
            .sink { [weak self] cwd in
                self?.currentDirectory = cwd
                print("currentDirectory: \(cwd)")
            }
            .store(in: &viewModel.cancellables)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(viewModel, forKey: .viewModel)
        try container.encode(currentDirectory, forKey: .currentDirectory)
    }

    static func == (lhs: Tab, rhs: Tab) -> Bool {
        return lhs.id == rhs.id && lhs.viewModel.id == rhs.viewModel.id && lhs.title == rhs.title
            && lhs.currentDirectory == rhs.currentDirectory
    }
}