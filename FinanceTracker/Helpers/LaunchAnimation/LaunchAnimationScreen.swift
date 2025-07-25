import SwiftUI

struct LaunchAnimationScreen: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        LottieView(filename: "launch_animation") {
            DispatchQueue.main.async {
                appState.didShowLaunchAnimation = true
            }
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.white)
    }
}
