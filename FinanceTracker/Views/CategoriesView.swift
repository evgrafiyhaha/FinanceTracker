import SwiftUI

struct CategoriesView: View {

    @StateObject private var viewModel = CategoriesViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("СТАТЬИ") {
                    ForEach(viewModel.filteredItems, id: \.id) { item in
                        HStack {
                            Text(String(item.emoji))
                                .font(.system(size: 14.5))
                                .padding(4)
                                .background(.ftLightGreen)
                                .clipShape(Circle())
                            Text(item.name)
                        }
                    }
                }
            }
            .navigationTitle("Мои статьи")
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search")
        }
        .task { await viewModel.fetchCategories() }
    }
}

// MARK: - Preview

#Preview {
    CategoriesView()
}
