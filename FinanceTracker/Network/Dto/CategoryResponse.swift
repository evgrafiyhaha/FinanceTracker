
struct CategoryResponse: Decodable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
}

// MARK: - Mapper
extension Category {
    init(response: CategoryResponse) {
        self.id = response.id
        self.name = response.name
        self.emoji = response.emoji.first ?? "?"
        self.direction = response.isIncome ? .income : .outcome
    }
}
