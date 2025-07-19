import SwiftData
import Foundation

@MainActor
final class SwiftDataCategoriesStorage: CategoriesStorage {
    private let context: ModelContext = SwiftDataStorage.shared.context

    func categories() async throws -> [Category] {
        try context.fetch(FetchDescriptor<CategoryModel>())
            .map { $0.toDomain() }
    }

    func sync(categories: [Category]) async throws {
        for category in categories {
            try await add(category)
        }
    }

    private func add(_ category: Category) async throws {
        let model = CategoryModel(from: category)
        context.insert(model)
        try context.save()
    }
}

