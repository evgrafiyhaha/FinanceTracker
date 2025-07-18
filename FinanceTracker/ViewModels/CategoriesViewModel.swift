import Foundation

final class CategoriesViewModel: ObservableObject {

    // MARK: - @Published
    @Published private(set) var categories: [Category] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    // MARK: - Public Properties
    weak var appState: AppState?
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

    // MARK: - Private Properties
    private let categoriesService = CategoriesService()

    // MARK: - Public Methods
    func fetchCategories() async {
        await MainActor.run { isLoading = true; error = nil }
        defer { Task { @MainActor in isLoading = false } }

        do {
            let categories = try await categoriesService.categories()
            await MainActor.run {
                self.appState?.isOffline = false
                self.categories = categories
            }
        } catch {
            handleError(error, context: "CategoriesViewModel.fetchCategories")
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

    private func handleError(_ error: Error, context: String) {
        Task { @MainActor in
            var description = ""
            self.appState?.isOffline = true
            switch error {
            case CategoriesServiceError.networkFallback(let categories, let nestedError):
                self.categories = categories
                description = (nestedError as? LocalizedError)?.errorDescription ?? "Ошибка сети: данные могут быть неактуальными"
            default:
                description = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка"
            }
            self.error = description
            print("[\(context)] - Ошибка: \(error)")
        }
    }
}
