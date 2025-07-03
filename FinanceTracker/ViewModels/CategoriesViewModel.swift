import Foundation
import Fuse

final class CategoriesViewModel: ObservableObject {

    // MARK: - @Published
    @Published private(set) var categories: [Category] = []
    @Published var searchText: String = ""

    // MARK: - Public Properties
    var filteredCategories: [Category] {
        guard !searchText.isEmpty else { return categories }

        return categories.compactMap { category in
            if let result = fuse.search(searchText, in: category.name),
               result.score < 0.5 {
                return (category, result.score)
            } else {
                return nil
            }
        }
        .sorted { $0.1 < $1.1 }
        .map { $0.0 }
    }

    // MARK: - Private Properties
    private let categoriesService = CategoriesService()
    private let fuse = Fuse()

    // MARK: - Public Methods
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
