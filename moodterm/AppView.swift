import SwiftUI

struct AppView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(appState: appState, fontSizeFactor: $appState.fontSizeFactor)
            .onAppear {
                appState.selectedTab = appState.tabs.first?.id
                appState.observeTabChanges()
            }
            .onChange(of: appState.tabs) {
                appState.observeTabChanges()
            }
    }
}