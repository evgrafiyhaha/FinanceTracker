import Foundation

struct TransactionResponse: Decodable {
    let id: Int
    let account: BankAccountResponse
    let category: CategoryResponse
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
}

extension Transaction {
    init(response: TransactionResponse, with formatter: ISO8601DateFormatter) {
        self.id = response.id
        self.account = BankAccount(response: response.account,with: formatter)
        self.category = Category(response: response.category)
        self.amount = Decimal(string: response.amount) ?? 0
        let createdAtStr = response.createdAt
        let updatedAtStr = response.updatedAt
        let transactionDateStr = response.transactionDate
        self.transactionDate = formatter.date(from: transactionDateStr) ?? Date()
        self.comment = response.comment
        self.createdAt = formatter.date(from: createdAtStr) ?? Date()
        self.updatedAt = formatter.date(from: updatedAtStr) ?? Date()

    }
}
