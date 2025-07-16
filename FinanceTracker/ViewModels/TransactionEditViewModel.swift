import Combine
import Foundation

enum TransactionEditState {
    case edit
    case create
}

final class TransactionEditViewModel: ObservableObject {

    // MARK: - @Published
    @Published var category: Category?
    @Published var amount: Decimal?
    @Published var transactionDate =  Date()
    @Published var comment: String = ""
    @Published private(set) var categories: [Category] = []
    @Published var amountString: String = ""
    @Published private(set) var currency: Currency = .usd
    private var bankAccount: BankAccount?

    // MARK: - Public Properties
    let state: TransactionEditState

    // MARK: - Private Properties
    private var transaction: Transaction?
    private let direction: Direction
    private let categoriesService = CategoriesService()
    private let accountService = BankAccountsService.shared
    private let transactionsService = TransactionsService.shared

    // MARK: - init
    init(_ transaction: Transaction?, direction: Direction) {
        self.direction = direction
        if let transaction {
            self.state = .edit
            self.transaction = transaction
            category = transaction.category
            amountString = transaction.amount.formatted()
            amount = transaction.amount
            transactionDate = transaction.transactionDate
            comment = transaction.comment ?? ""
        } else {
            self.state = .create
        }
    }

    // MARK: - Public Methods
    func loadData() async {
        await fetchCategories()
        await fetchAccount()
    }

    func deleteTransaction()  {
        guard let transaction else { return }
        Task {
            do {
                try await transactionsService.delete(withId: transaction.id)
            } catch {
                print("[TransactionEditViewModel.deleteTransaction] - Ошибка удаления операции: \(error)")
            }
        }
    }

    func saveTransaction() {
        guard
            let category,
            let amount,
            let bankAccount
        else {
            return
        }
        switch state {
        case .create:
            Task {
                do {
                    try await transactionsService.add(
                        Transaction(
                            id: -1,
                            account: bankAccount,
                            category: category,
                            amount: amount,
                            transactionDate: transactionDate,
                            comment: comment == "" ? nil : comment,
                            createdAt: Date(),
                            updatedAt: Date()
                        )
                    )
                } catch {
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case let .httpError(statusCode, data):
                            print("Status code: \(statusCode)")
                            print("Response body:", String(data: data, encoding: .utf8) ?? "nil")
                        default:
                            print("Другая ошибка:", networkError)
                        }
                    } else {
                        print("Неизвестная ошибка типа:", error)
                    }

                }
            }
        case .edit:
            guard let transaction else {
                return
            }
            Task {
                do {
                    let updated = Transaction(
                        id: transaction.id,
                        account: bankAccount,
                        category: category,
                        amount: amount,
                        transactionDate: transactionDate,
                        comment: comment == "" ? nil : comment,
                        createdAt: transaction.createdAt,
                        updatedAt: Date()
                    )
                    try await transactionsService.update(
                        withId: transaction.id,
                        with: updated
                    )
                } catch {
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case let .httpError(statusCode, data):
                            print("Status code: \(statusCode)")
                            print("Response body:", String(data: data, encoding: .utf8) ?? "nil")
                        default:
                            print("Другая ошибка:", networkError)
                        }
                    } else {
                        print("Неизвестная ошибка типа:", error)
                    }
                }
            }
        }
    }

    func updateBalance() {
        let normalized = amountString
            .components(separatedBy: .whitespacesAndNewlines).joined()
            .replacingOccurrences(of: ",", with: ".")
        if let value = Decimal(string: normalized) {
            amountString = value.formatted()
            amount = value
        } else {
            amountString = ""
            amount = nil
        }
    }

    // MARK: - Private Methods
    private func fetchCategories() async {
        do {
            let categories = try await categoriesService.categories(withDirection: direction)
            await MainActor.run {
                self.categories = categories
            }
        }
        catch {
            print("[TransactionEditViewModel.fetchCategories] - Ошибка загрузки статей: \(error)")
        }
    }

    private func fetchAccount() async {
        do {
            let account = try await accountService.bankAccount()
            await MainActor.run {
                self.bankAccount = account
                self.currency = account.currency
            }
        }
        catch {
            print("[AccountViewModel.fetchAccount] - Ошибка загрузки счета: \(error)")
        }
    }
}
