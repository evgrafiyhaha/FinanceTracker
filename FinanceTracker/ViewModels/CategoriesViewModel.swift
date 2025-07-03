import Foundation


final class CategoriesViewModel: ObservableObject {

    // MARK: - @Published
    @Published private(set) var categories: [Category] = []
    @Published var searchText: String = ""

        var filteredItems: [Category] {
            if searchText.isEmpty {
                return categories
            } else {
                return categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }

    // MARK: - Private Properties
    private let categoriesService = CategoriesService()

    func fetchCategories() async {
        do {
            let categories = try await categoriesService.categories()
            await MainActor.run {
                self.categories = categories
            }
        }
        catch {
            print("[CategoriesViewModel.fetchCategories] - Ошибка загрузки статей: \(error)")
        }
    }
}
