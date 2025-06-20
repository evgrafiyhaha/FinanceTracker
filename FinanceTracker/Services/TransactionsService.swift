import Foundation

enum TransactionsServiceError: Error {
    case notFound
    case alreadyExists
}

final class TransactionsService {

    // MARK: - Static Properties
    static let categories: [Category] = [
        Category(id: 0, name: "Зарплата", emoji: "💰", direction: .income),
        Category(id: 1, name: "Аренда", emoji: "🏠", direction: .outcome),
        Category(id: 2, name: "Ремонт", emoji: "🛠", direction: .outcome),
        Category(id: 3, name: "Подработка", emoji: "👤", direction: .income)
    ]
    static let bankAccount: BankAccount = BankAccount(id: 0, userId: 0, name: "Основной счёт", balance: 1000.00, currency: .rub, createdAt: Date(), updatedAt: Date())

    // MARK: - Private Properties
    var transactions: [Transaction] = [
        Transaction(id: 0, account: bankAccount, category: categories[0], amount: 77700.00, transactionDate: Date().addingTimeInterval(-86400), comment: nil, createdAt: Date(), updatedAt: Date()),
        Transaction(id: 1, account: bankAccount, category: categories[1], amount: 8555.00, transactionDate: Date().addingTimeInterval(-86400), comment: "Арендодатель хочет кушать", createdAt: Date(), updatedAt: Date()),
        Transaction(id: 2, account: bankAccount, category: categories[2], amount: 3933.00, transactionDate: Date(), comment: "Сломалось все", createdAt: Date(), updatedAt: Date()),
        Transaction(id: 3, account: bankAccount, category: categories[0], amount: 777000.00, transactionDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), comment: "пасхалка", createdAt: Date(), updatedAt: Date()),
        Transaction(id: 4, account: bankAccount, category: categories[1], amount: 5595.00, transactionDate: Date(), comment: "Арендодатель хочет кушать", createdAt: Date(), updatedAt: Date()),
        Transaction(id: 5, account: bankAccount, category: categories[2], amount: 3337.00, transactionDate: Date().addingTimeInterval(-86400), comment: "Сломалась плитка", createdAt: Date(), updatedAt: Date()),
        Transaction(id: 6, account: bankAccount, category: categories[3], amount: 77700.00, transactionDate: Date(), comment: nil, createdAt: Date(), updatedAt: Date()),
        Transaction(id: 7, account: bankAccount, category: categories[1], amount: 5855.00, transactionDate: Date(), comment: "Арендодатель хочет кушать", createdAt: Date(), updatedAt: Date()),
        Transaction(id: 8, account: bankAccount, category: categories[2], amount: 520000.00, transactionDate: Date(), comment: "Сломался ковер", createdAt: Date(), updatedAt: Date()),
        Transaction(id: 11, account: bankAccount, category: categories[3], amount: 7700.00, transactionDate: Date(), comment: nil, createdAt: Date(), updatedAt: Date()),
        Transaction(id: 9, account: bankAccount, category: categories[1], amount: 5585.00, transactionDate: Date().addingTimeInterval(-86400), comment: nil, createdAt: Date(), updatedAt: Date()),
        Transaction(id: 10, account: bankAccount, category: categories[2], amount: 3373.00, transactionDate: Date(), comment: "Сломалась плитка", createdAt: Date(), updatedAt: Date())
    ]

    // MARK: - Public Methods
    func transactions(from: Date, to: Date) async throws -> [Transaction] {
        return transactions.filter {
            $0.transactionDate >= from && $0.transactionDate <= to
        }
    }

    func add(_ transaction: Transaction) async throws {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            print("[TransactionsService.add] - Транзакция с id \(transaction.id) уже существует")
            throw TransactionsServiceError.alreadyExists
        }
        transactions.append(transaction)
    }

    func update(withId id: Int, with transaction: Transaction) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            print("[TransactionsService.update] - Транзакция с id \(id) не найдена")
            throw TransactionsServiceError.notFound
        }
        transactions[index] = transaction
    }

    func delete(withId id: Int) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            print("[TransactionsService.update] - Транзакция с id \(id) не найдена")
            throw TransactionsServiceError.notFound
        }
        transactions.remove(at: index)
    }
}

