import Combine
import SwiftUI

/// A class that manages the user settings of the application.
class UserSettings: ObservableObject {
    @Published var fontSizeFactor: Double {
        didSet {
            UserDefaults.standard.set(fontSizeFactor, forKey: "fontSizeFactor")
        }
    }

    init() {
        if let savedFontSizeFactor = UserDefaults.standard.value(forKey: "fontSizeFactor")
            as? Double
        {
            self.fontSizeFactor = savedFontSizeFactor
        } else {
            self.fontSizeFactor = 1.0  // Default value
        }
    }
}
