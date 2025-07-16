import Foundation

struct TransactionRequest: Encodable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: AlwaysEncoded<String>
}

extension TransactionRequest {
    init(from model: Transaction, with formatter: ISO8601DateFormatter) {
        self.accountId = model.account.id
        self.categoryId = model.category.id
        self.amount = String(format: "%.2f", NSDecimalNumber(decimal: model.amount).doubleValue)
        self.transactionDate = formatter.string(from: model.transactionDate)
        if let comment = model.comment, !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.comment = AlwaysEncoded(value: comment)
        } else {
            self.comment = AlwaysEncoded(value: nil)
        }
    }
}
