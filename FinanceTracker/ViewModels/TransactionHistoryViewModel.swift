import Foundation
import Combine

enum SortingType {
    case date
    case amount
    case none

    var name: String {
        switch self {
        case .date:
            return "По дате"
        case .amount:
            return "По сумме"
        case .none:
            return "Не выбрана"
        }
    }
}

final class TransactionHistoryViewModel: ObservableObject {

    // MARK: - @Published
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var sum: Decimal = 0
    @Published private(set) var bankAccount: BankAccount?
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    @Published var sortingType: SortingType = .none
    @Published var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date() {
        didSet {
            if startDate > endDate {
                endDate = startDate
            }
        }
    }
    @Published var endDate: Date = Date() {
        didSet {
            if startDate > endDate {
                startDate = endDate
            }
        }
    }

    weak var appState: AppState?

    // MARK: - Private Properties
    private let direction: Direction
    private let transactionsService = TransactionsService.shared
    private let accountService = BankAccountsService.shared
    private var fetchTask: Task<Void, Never>?

    // MARK: - init
    init(direction: Direction) {
        self.direction = direction
    }

    // MARK: - Public Methods
    func load() async {
        await MainActor.run { isLoading = true; error = nil }
        defer { Task { @MainActor in isLoading = false } }

        await fetchTransactions()
        await fetchAccount()
    }

    func applySort() {
        switch sortingType {
        case .date:
            transactions.sort { $0.transactionDate > $1.transactionDate }
        case .amount:
            transactions.sort { $0.amount > $1.amount }
        case .none:
            return
        }
    }

    func changeDatePeriod() {
        fetchTask?.cancel()
        fetchTask = Task {
            await fetchTransactions()
        }
    }

    // MARK: - Private Methods
    private func recalculateSum() {
        sum = transactions.reduce(0) { $0 + $1.amount }
    }

    private func fetchAccount() async {
        do {
            let account = try await accountService.bankAccount()
            await MainActor.run {
                self.appState?.isOffline = false
                self.bankAccount = account
                self.recalculateSum()
            }
        } catch {
            handleError(error, context: "TransactionHistoryViewModel.fetchAccount")
        }
    }

    private func fetchTransactions() async {
        guard !Task.isCancelled else { return }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) else {
            return
        }
        do {
            let all = try await transactionsService.transactions(from: startOfDay, to: endOfDay)
            let filtered = all.filter { $0.category.direction == direction }

            await MainActor.run {
                self.appState?.isOffline = false
                self.transactions = filtered
                self.applySort()
                self.recalculateSum()
            }
        } catch {
            handleError(error, context: "TransactionHistoryViewModel.fetchTransactions")
        }
    }
    
    private func handleError(_ error: Error, context: String) {
        Task { @MainActor in
            var description = ""
            self.appState?.isOffline = true
            switch error {
            case TransactionsServiceError.networkFallback(let transactions, let nestedError):
                self.transactions = transactions
                self.applySort()
                self.recalculateSum()
                description = (nestedError as? LocalizedError)?.errorDescription ?? "Ошибка сети: данные могут быть неактуальными"
            case BankAccountsServiceError.networkFallback(let account, let nestedError):
                self.bankAccount = account
                self.recalculateSum()
                description = (nestedError as? LocalizedError)?.errorDescription ?? "Ошибка сети: данные могут быть неактуальными"
            default:
                description = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка"
            }
            self.error = description
            print("[\(context)] - Ошибка: \(error)")
        }
    }
}
