import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
//            if appState.isOffline {
//                Text("Offline mode")
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.red)
//                    .transition(.move(edge: .top))
//            }
            TabView {
                TransactionsListView(direction: .outcome)
                    .tabItem {
                        Image("downtrend").renderingMode(.template)
                        Text("Расходы")
                    }

                TransactionsListView(direction: .income)
                    .tabItem {
                        Image("uptrend").renderingMode(.template)
                        Text("Доходы")
                    }

                AccountView()
                    .tabItem {
                        Image("calculator").renderingMode(.template)
                        Text("Счет")
                    }

                CategoriesView()
                    .tabItem {
                        Image("categories").renderingMode(.template)
                        Text("Статьи")
                    }

                SettingsView()
                    .tabItem {
                        Image("settings").renderingMode(.template)
                        Text("Настройки")
                    }
            }
        }
        .animation(.easeInOut, value: appState.isOffline)

    }
}

// MARK: - Preview

#Preview {
    TabBarView()
}
