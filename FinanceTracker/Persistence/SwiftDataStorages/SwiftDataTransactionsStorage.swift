import SwiftData
import Foundation

@MainActor
final class SwiftDataTransactionsStorage: TransactionsStorage {
    
    private let context: ModelContext = SwiftDataStorage.shared.context

    func sync(transactions: [Transaction]) async throws {
        for transaction in transactions {
            try await add(transaction)
        }
    }

    func transactions() async throws -> [Transaction] {
        try context.fetch(FetchDescriptor<TransactionModel>())
            .map { $0.toDomain() }
    }

    func add(_ transaction: Transaction) async throws {
        let model = try TransactionModel(from: transaction, in: context)
        context.insert(model)
        try context.save()
    }

    func update(_ transaction: Transaction) async throws {
        let transactionId = transaction.id
        let descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate { $0.id == transactionId }
        )
        guard let existing = try context.fetch(descriptor).first else {
            throw NSError(domain: "Transaction not found", code: 1)
        }
        let accountId = transaction.account.id
        let accountFetch = FetchDescriptor<BankAccountModel>(
            predicate: #Predicate { $0.id == accountId }
        )
        let accountModel = try context.fetch(accountFetch).first ?? {
            let newAccount = BankAccountModel(from: transaction.account)
            context.insert(newAccount)
            return newAccount
        }()
        let categoryId = transaction.category.id
        let categoryFetch = FetchDescriptor<CategoryModel>(
            predicate: #Predicate { $0.id == categoryId }
        )
        let categoryModel = try context.fetch(categoryFetch).first ?? {
            let newCategory = CategoryModel(from: transaction.category)
            context.insert(newCategory)
            return newCategory
        }()

        existing.account = accountModel
        existing.category = categoryModel
        existing.amount = transaction.amount
        existing.transactionDate = transaction.transactionDate
        existing.comment = transaction.comment
        existing.createdAt = transaction.createdAt
        existing.updatedAt = transaction.updatedAt

        try context.save()
    }

    func delete(id: Int) async throws {
        let descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let object = try context.fetch(descriptor).first {
            context.delete(object)
            try context.save()
        }
    }
}
