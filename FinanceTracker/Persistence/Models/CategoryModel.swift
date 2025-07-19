import Foundation
import SwiftData

@Model
final class CategoryModel {
    @Attribute(.unique) var id: Int
    var name: String
    var emoji: String
    var isIncome: Bool

    init(from category: Category) {
        self.id = category.id
        self.name = category.name
        self.emoji = String(category.emoji)
        self.isIncome = category.direction == .income ? true : false
    }
}

extension CategoryModel {
    func toDomain() -> Category {
        Category(
            id: self.id,
            name: self.name,
            emoji: self.emoji.first ?? "?",
            direction: self.isIncome ? .income : .outcome
        )
    }
}
