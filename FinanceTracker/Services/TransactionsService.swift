import Foundation

enum TransactionsServiceError: Error {
    case notFound
    case alreadyExists
}

final class TransactionsService {
    static let categories: [Category] = [
        Category(id: 0, name: "Зарплата", emoji: "💰", direction: .income),
        Category(id: 1, name: "Аренда", emoji: "🏠", direction: .outcome),
        Category(id: 2, name: "Ремонт", emoji: "🛠", direction: .outcome)
    ]
    static let bankAccount: BankAccount = BankAccount(id: 0, userId: 0, name: "Основной счёт", balance: 1000.00, currency: .rub, createdAt: Date(), updatedAt: Date())

    private var transactions: [Transaction] = [
        Transaction(id: 0, account: bankAccount, category: categories[0], amount: 777.00, transactionDate: Date(), comment: "Подработка", createdAt: Date(), updatedAt: Date()),
        Transaction(id: 1, account: bankAccount, category: categories[1], amount: 555.00, transactionDate: Date(), comment: "Арендодатель хочет кушать", createdAt: Date(), updatedAt: Date()),
        Transaction(id: 2, account: bankAccount, category: categories[2], amount: 333.00, transactionDate: Date(), comment: "Сломалась плитка", createdAt: Date(), updatedAt: Date())
    ]

    func transactions(from: Date, to: Date) async throws -> [Transaction] {
        return transactions.filter {
            $0.transactionDate >= from && $0.transactionDate <= to
        }
    }

    func add(_ transaction: Transaction) async throws {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            throw TransactionsServiceError.alreadyExists
        }
        transactions.append(transaction)
    }

    func update(withId id: Int, with transaction: Transaction) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw TransactionsServiceError.notFound
        }
        transactions[index] = transaction
    }

    func delete(withId id: Int) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw TransactionsServiceError.notFound
        }
        transactions.remove(at: index)
    }
}

