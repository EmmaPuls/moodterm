import SwiftUI

// TODO: Implement a logger for the application instead of using print statements

@main
struct MoodtermApp: App {
    @StateObject private var tabStore = TabStore()
    @StateObject private var userSettings = UserSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabStore)
                .environmentObject(userSettings)
        }
        .commands {
            FontSizeCommands(fontSizeFactor: $userSettings.fontSizeFactor)
        }
    }
}
