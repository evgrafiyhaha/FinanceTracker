import Foundation

enum BankAccountsServiceError: Error {
    case notFound
}

final class BankAccountsService {
    private var allAccounts: [BankAccount] = [
        BankAccount(id: 0, userId: 0, name: "Основной счёт", balance: 1000.00, currency: .rub, createdAt: Date(), updatedAt: Date()),
        BankAccount(id: 1, userId: 0, name: "Запасной счёт", balance: 52.00, currency: .rub, createdAt: Date(), updatedAt: Date())
    ]

    func bankAccount() async throws -> BankAccount {
        guard let first = allAccounts.first else {
            throw BankAccountsServiceError.notFound
        }
        return first
    }

    func updateBalance(withValue value: Decimal) async throws {
        guard let first = allAccounts.first else {
            throw BankAccountsServiceError.notFound
        }
        let updatedAccount = BankAccount(
            id: first.id,
            userId: first.userId,
            name: first.name,
            balance: first.balance + value,
            currency: first.currency,
            createdAt: first.createdAt,
            updatedAt: Date()
        )
        allAccounts[0] = updatedAccount
    }
}
