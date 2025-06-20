import SwiftUI

struct TabBarView: View {

    var body: some View {
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
        .accentColor(.ftGreen)

    }
}

// MARK: - Preview

#Preview {
    TabBarView()
}
