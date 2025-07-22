@MainActor
protocol CategoriesStorage {
    func categories() async throws -> [Category]
    func sync(categories: [Category]) async throws
}
