import SwiftData
import Foundation

@Model
final class TransactionModel {
    @Attribute(.unique) var id: Int
    var account: BankAccountModel
    var category: CategoryModel
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date

    init(from transaction: Transaction, in context: ModelContext) throws {
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

        self.id = transaction.id
        self.account = accountModel
        self.category = categoryModel
        self.amount = transaction.amount
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment
        self.createdAt = transaction.createdAt
        self.updatedAt = transaction.updatedAt
    }
}

extension TransactionModel {
    func toDomain() -> Transaction {
        Transaction(
            id: self.id,
            account: self.account.toDomain(),
            category: self.category.toDomain(),
            amount: self.amount,
            transactionDate: self.transactionDate,
            comment: self.comment,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
