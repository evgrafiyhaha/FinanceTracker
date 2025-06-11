import SwiftUI

struct TabBarView: View {

    // MARK: - Body
    var body: some View {
        TabView {
            ExpensesView()
                .tabItem {
                    Image("downtrend").renderingMode(.template)
                    Text("Расходы")
                }

            IncomeView()
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
        .accentColor(.customGreen)

    }
}

// MARK: - Preview

#Preview {
    TabBarView()
}
