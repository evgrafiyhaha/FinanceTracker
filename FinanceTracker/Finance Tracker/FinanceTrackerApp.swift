import SwiftUI
import Lottie

@main
struct FinanceTrackerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if appState.didShowLaunchAnimation {
                TabBarView()
                    .environmentObject(appState)
            } else {
                LaunchAnimationScreen()
                    .environmentObject(appState)
            }
        }
    }
}
