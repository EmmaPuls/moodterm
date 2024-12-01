import SwiftUI

/// The main view of the application.
struct ContentView: View {
    @EnvironmentObject var tabStore: TabStore
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        TabView(
            tabs: $tabStore.tabs, selectedTab: $tabStore.selectedTab,
            fontSizeFactor: $userSettings.fontSizeFactor
        )
        .onAppear {
            tabStore.selectedTab = tabStore.tabs.first?.id
        }
    }
}
