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
            let query = searchText.lowercased()
            let name = category.name.lowercased()

            if name.contains(query) {
                return (category, 0.0)
            }

            let distanceValue = distance(query, name)
            let maxLen = max(query.count, name.count)
            let score = Double(distanceValue) / Double(maxLen)

            if score < 0.5 {
                return (category, score)
            } else {
                return nil
            }
        }
        .sorted { $0.1 < $1.1 }
        .map { $0.0 }
    }
    //    private let fuse = Fuse()
    // Альтернативный вариант с использованием Fuse
    //    var filteredCategories: [Category] {
    //        guard !searchText.isEmpty else { return categories }
    //
    //        return categories.compactMap { category in
    //            if let result = fuse.search(searchText, in: category.name),
    //               result.score < 0.5 {
    //                return (category, result.score)
    //            } else {
    //                return nil
    //            }
    //        }
    //        .sorted { $0.1 < $1.1 }
    //        .map { $0.0 }
    //    }

    // MARK: - Private Properties
    private let categoriesService = CategoriesService()

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

    // MARK: - Private Methods
    func distance(_ a: String, _ b: String) -> Int {
        let a = Array(a)
        let b = Array(b)
        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)

        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }
        return dist[a.count][b.count]
    }
}
