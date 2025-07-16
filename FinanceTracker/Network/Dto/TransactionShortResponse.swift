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
}
