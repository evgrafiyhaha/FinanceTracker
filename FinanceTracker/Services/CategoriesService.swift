final class CategoriesService {

    // MARK: - Private Properties
    private let allCategories: [Category] = [
        Category(id: 0, name: "Зарплата", emoji: "💰", direction: .income),
        Category(id: 1, name: "Аренда", emoji: "🏠", direction: .outcome),
        Category(id: 2, name: "Ремонт", emoji: "🛠", direction: .outcome),
        Category(id: 7, name: "На собачку", emoji: "🐕", direction: .outcome),
        Category(id: 4, name: "Одежда", emoji: "👔", direction: .outcome),
        Category(id: 5, name: "Спортзал", emoji: "🏋️‍♂️", direction: .outcome),
        Category(id: 6, name: "Машина", emoji: "🚗", direction: .outcome),
        Category(id: 3, name: "Подработка", emoji: "👤", direction: .income)
    ]

    // MARK: - Public Methods
    func categories() async throws -> [Category] {
        return allCategories
    }

    func categories(withDirection direction: Direction) async throws -> [Category] {
        return allCategories.filter { $0.direction == direction }
    }
}
