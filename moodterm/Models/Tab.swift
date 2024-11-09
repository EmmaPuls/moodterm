import Foundation

///  Defines the `Tab` class, which represents a terminal tab.
class Tab: Identifiable, Codable, Equatable, Observable {
    let id: UUID
    /// The title of the tab.
    var title: String
    // TODO: Consider making this a protocol
    var viewModel: TerminalViewModel

    init(id: UUID = UUID(), title: String, viewModel: TerminalViewModel) {
        self.id = id
        self.title = title
        self.viewModel = viewModel
    }

    enum CodingKeys: String, CodingKey {
        case id, title, viewModel
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        viewModel = try container.decode(TerminalViewModel.self, forKey: .viewModel)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(viewModel, forKey: .viewModel)
    }

    static func == (lhs: Tab, rhs: Tab) -> Bool {
        return lhs.id == rhs.id && lhs.viewModel.id == rhs.viewModel.id
    }
}
