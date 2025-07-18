import SwiftUI

@main
struct FinanceTrackerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(appState)
        }
    }
}
