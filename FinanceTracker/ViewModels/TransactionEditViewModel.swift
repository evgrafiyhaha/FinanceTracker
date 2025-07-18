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
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
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
        await MainActor.run { isLoading = true; error = nil }
        defer { Task { @MainActor in isLoading = false } }

        await fetchCategories()
        await fetchAccount()
    }

    func deleteTransaction()  async {
        await MainActor.run { isLoading = true; error = nil }
        defer { Task { @MainActor in isLoading = false } }

        guard let transaction else { return }
        do {
            try await transactionsService.delete(withId: transaction.id)
        } catch {
            handleError(error, context: "TransactionEditViewModel.deleteTransaction")
        }
    }

    func saveTransaction() async {
        await MainActor.run { isLoading = true; error = nil }
        defer { Task { @MainActor in isLoading = false } }

        guard
            let category,
            let amount,
            let bankAccount
        else {
            return
        }
        switch state {
        case .create:
            do {
                let tempId = Int(Date().timeIntervalSince1970 * 1000) * -1
                try await transactionsService.add(
                    Transaction(
                        id: tempId,
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
                handleError(error, context: "TransactionEditViewModel.saveTransaction")
            }
        case .edit:
            guard let transaction else {
                return
            }
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
                handleError(error, context: "TransactionEditViewModel.saveTransaction")
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
        } catch {
            handleError(error, context: "TransactionEditViewModel.fetchCategories")
        }
    }

    private func fetchAccount() async {
        do {
            let account = try await accountService.bankAccount()
            await MainActor.run {
                self.bankAccount = account
                self.currency = account.currency
            }
        } catch {
            handleError(error, context: "TransactionEditViewModel.fetchAccount")
        }
    }

    private func handleError(_ error: Error, context: String) {
        Task { @MainActor in
            var description = ""
            switch error {
            case CategoriesServiceError.networkFallback(let categories, let nestedError):
                self.categories = categories
                description = (nestedError as? LocalizedError)?.errorDescription ?? "Ошибка сети: данные могут быть неактуальными"
            case BankAccountsServiceError.networkFallback(let account, let nestedError):
                self.bankAccount = account
                self.currency = account.currency
                description = (nestedError as? LocalizedError)?.errorDescription ?? "Ошибка сети: данные могут быть неактуальными"
            default:
                description = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка"
            }
            self.error = description
            print("[\(context)] - Ошибка: \(error)")
        }
    }
}
