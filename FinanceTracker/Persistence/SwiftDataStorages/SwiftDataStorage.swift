import SwiftData

@MainActor
final class SwiftDataStorage {
    static let shared = SwiftDataStorage()

    let container: ModelContainer
    let context: ModelContext

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
