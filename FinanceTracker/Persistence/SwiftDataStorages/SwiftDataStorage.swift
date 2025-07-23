import SwiftData

@MainActor
final class SwiftDataStorage {
    // MARK: - Static Properties
    static let shared = SwiftDataStorage()

    // MARK: - Public Properties
    let container: ModelContainer
    let context: ModelContext

    // MARK: - Init
    private init() {
        let schema = Schema([
            TransactionModel.self,
            PendingTransactionModel.self,
            BankAccountModel.self,
            CategoryModel.self
        ])
        self.container = try! ModelContainer(for: schema)
        self.context = ModelContext(container)
    }
}
