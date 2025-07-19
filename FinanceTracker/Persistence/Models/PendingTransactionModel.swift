import SwiftData
import Foundation

@Model
final class PendingTransactionModel {
    @Attribute(.unique) var id: Int
    var operation: String
    var transaction: TransactionModel?
    var transactionId: Int

    init(from pendingTransaction: PendingTransaction, in context: ModelContext) throws {
        self.id = pendingTransaction.id
        self.operation = pendingTransaction.operation.rawValue
        let transactionId = pendingTransaction.transactionId
        self.transactionId = transactionId
        let descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate { $0.id == transactionId }
        )
        if let existing = try context.fetch(descriptor).first {
            self.transaction = existing
        } else {
            guard let transaction = pendingTransaction.transaction else {
                self.transaction = nil
                return
            }
            let newTransaction = try TransactionModel(from: transaction, in: context)
            context.insert(newTransaction)
            self.transaction = newTransaction
        }
    }
}

extension PendingTransactionModel {
    func toDomain() -> PendingTransaction {
        .init(
            id: self.id,
            operation: .init(rawValue: self.operation) ?? .add,
            transactionId: self.transactionId,
            transaction: self.transaction?.toDomain()
        )
    }
}
