import SwiftData
import Foundation

@MainActor
final class SwiftDataBackupStorage {
    private let context: ModelContext = SwiftDataStorage.shared.context

    func pendingTransactions() async throws -> [PendingTransaction] {
        try context.fetch(FetchDescriptor<PendingTransactionModel>())
            .map { $0.toDomain() }
    }

    func add(_ pendingTransaction: PendingTransaction) async throws {
        let model = try PendingTransactionModel(from: pendingTransaction, in: context)
        context.insert(model)
        try context.save()
    }

    func delete(id: Int) async throws {
        let descriptor = FetchDescriptor<PendingTransactionModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let object = try context.fetch(descriptor).first {
            context.delete(object)
            try context.save()
        }
    }
}
