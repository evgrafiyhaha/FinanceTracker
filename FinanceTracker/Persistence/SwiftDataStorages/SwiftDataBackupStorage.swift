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

    func add(transaction: Transaction?, transactionId: Int? = nil, for operation: BackupOperation) async throws {
        let newId = try nextId()

        if operation == .delete, let transactionId = transactionId {
            let pending = PendingTransaction(id: newId, operation: operation, transactionId: transactionId, transaction: transaction)

            let model = try PendingTransactionModel(from: pending, in: context)
            context.insert(model)

        } else {
            guard let transaction = transaction else {
                return
            }
            let pending = PendingTransaction(id: newId, operation: operation, transactionId: transaction.id, transaction: transaction)

            let model = try PendingTransactionModel(from: pending, in: context)
            context.insert(model)
        }
        try context.save()
    }

    private func nextId() throws -> Int {
        let existing = try context.fetch(FetchDescriptor<PendingTransactionModel>())
        return (existing.map { $0.id }.max() ?? 0) + 1
    }
}
