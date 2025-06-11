final class CategoriesService {

    // MARK: - Private Properties
    private let allCategories: [Category] = [
        Category(id: 0, name: "Зарплата", emoji: "💰", direction: .income),
        Category(id: 1, name: "Аренда", emoji: "🏠", direction: .outcome),
        Category(id: 2, name: "Ремонт", emoji: "🛠", direction: .outcome)
    ]

    // MARK: - Public Methods
    func categories() async throws -> [Category] {
        return allCategories
    }

    func categories(withDirection direction: Direction) async throws -> [Category] {
        return allCategories.filter { $0.direction == direction }
    }
}
