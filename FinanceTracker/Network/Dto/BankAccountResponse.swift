import Foundation

struct BankAccountResponse: Decodable {
    let id: Int
    let userId: Int?
    let name: String
    let balance: String
    let currency: String
    let createdAt: String?
    let updatedAt: String?
}

extension BankAccount {
    init(response: BankAccountResponse, with formatter: ISO8601DateFormatter) {
        self.id = response.id
        self.userId = response.userId
        self.name = response.name
        self.balance = Decimal(string: response.balance) ?? 0
        self.currency = Currency(rawValue: response.currency) ?? .usd
        if let createdAtStr = response.createdAt {
            self.createdAt = formatter.date(from: createdAtStr)
        } else {
            self.createdAt = nil
        }
        if let updatedAtStr = response.updatedAt {
            self.updatedAt = formatter.date(from: updatedAtStr)
        } else {
            self.updatedAt = nil
        }
    }
}
