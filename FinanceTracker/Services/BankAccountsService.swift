import Foundation

enum BankAccountsServiceError: Error {
    case notFound
}

final class BankAccountsService {

    // MARK: - Private Properties
    private var allAccounts: [BankAccount] = [
        BankAccount(id: 0, userId: 0, name: "Основной счёт", balance: 1000.00, currency: .rub, createdAt: Date(), updatedAt: Date()),
        BankAccount(id: 1, userId: 0, name: "Запасной счёт", balance: 52.00, currency: .rub, createdAt: Date(), updatedAt: Date())
    ]

    // MARK: - Public Methods
    func bankAccount() async throws -> BankAccount {
        guard let first = allAccounts.first else {
            print("[BankAccountsService.bankAccount] - Не удалось найти ни одного банковского счёта")
            throw BankAccountsServiceError.notFound
        }
        return first
    }

    func update(with account: BankAccount) async throws {
        guard allAccounts.count > 0 else {
            print("[BankAccountsService.updateBalance] - Не удалось найти банковский счёт для обновления")
            throw BankAccountsServiceError.notFound
        }
        allAccounts[0] = account
    }

    func updateBalance(withValue value: Decimal) async throws {
        guard let first = allAccounts.first else {
            print("[BankAccountsService.updateBalance] - Не удалось найти банковский счёт для обновления")
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
