import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section("СТАТЬИ") {
                    ForEach(viewModel.filteredCategories, id: \.id) { category in
                        HStack {
                            EmojiView(emoji: category.emoji)
                            Text(category.name)
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
