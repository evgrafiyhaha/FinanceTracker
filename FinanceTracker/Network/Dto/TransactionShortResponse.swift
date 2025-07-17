import Foundation

struct TransactionShortResponse: Decodable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
}

extension TransactionShortResponse {
    init(from model: Transaction, with formatter: ISO8601DateFormatter) {
        self.id = model.id
        self.accountId = model.account.id
        self.categoryId = model.category.id
        self.amount = String(format: "%.2f", NSDecimalNumber(decimal: model.amount).doubleValue)
        self.transactionDate = formatter.string(from: model.transactionDate)
        self.comment = model.comment
        self.createdAt = formatter.string(from: model.createdAt)
        self.updatedAt = formatter.string(from: model.updatedAt)
    }
    
    func updated(transaction: Transaction,with formatter: ISO8601DateFormatter) -> Transaction {
        let createdAtStr = self.createdAt
        let updatedAtStr = self.updatedAt
        let transactionDateStr = self.transactionDate
        return Transaction(
            id: self.id,
            account: transaction.account,
            category: transaction.category,
            amount: Decimal(string: self.amount) ?? 0,
            transactionDate: formatter.date(from: transactionDateStr) ?? Date(),
            comment: self.comment,
            createdAt: formatter.date(from: createdAtStr) ?? Date(),
            updatedAt: formatter.date(from: updatedAtStr) ?? Date()
        )
    }
}
