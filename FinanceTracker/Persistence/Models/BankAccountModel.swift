import Foundation
import SwiftData

@Model
final class BankAccountModel {
    @Attribute(.unique) var id: Int
    var userId: Int?
    var name: String
    var balance: Decimal
    var currency: String
    var createdAt: Date?
    var updatedAt: Date?

    init(from account: BankAccount) {
        self.id = account.id
        self.userId = account.userId
        self.name = account.name
        self.balance = account.balance
        self.currency = account.currency.rawValue
        self.createdAt = account.createdAt
        self.updatedAt = account.updatedAt
    }
}

extension BankAccountModel {
    func toDomain() -> BankAccount {
        BankAccount(
            id: self.id,
            userId: self.userId,
            name: self.name,
            balance: self.balance,
            currency: .init(rawValue: self.currency) ?? .usd,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
