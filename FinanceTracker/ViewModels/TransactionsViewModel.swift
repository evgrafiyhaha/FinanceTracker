import Foundation
import Combine

final class TransactionsViewModel: ObservableObject {

    // MARK: - @Published
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var sum: Decimal = 0
    @Published private(set) var bankAccount: BankAccount?
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    weak var appState: AppState?

    // MARK: - Private Properties
    private let direction: Direction
    private let transactionsService = TransactionsService.shared
    private let accountService = BankAccountsService.shared

    // MARK: - init
    init(direction: Direction) {
        self.direction = direction
    }

    // MARK: - Public Methods
    func load() async {
        await MainActor.run { isLoading = true; error = nil }
        defer { Task { @MainActor in isLoading = false } }

        await fetchTodayTransactions()
        await fetchAccount()

    }

    // MARK: - Private Methods
    private func fetchTodayTransactions() async {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) else {
            return
        }
        do {
            let all = try await transactionsService.transactions(from: startOfDay, to: endOfDay)
            let filtered = all.filter { $0.category.direction == direction }

            await MainActor.run {
                self.appState?.isOffline = false
                self.transactions = filtered
                self.recalculateSum()
            }
        } catch {
            handleError(error, context: "TransactionsViewModel.fetchTodayTransactions")
        }
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
            handleError(error, context: "TransactionsViewModel.fetchAccount")
        }
    }

    private func recalculateSum() {
        sum = transactions.reduce(0) { $0 + $1.amount }
    }

    private func handleError(_ error: Error, context: String) {
        Task { @MainActor in
            var description = ""
            switch error {
            case TransactionsServiceError.networkFallback(let transactions, let nestedError):
                self.appState?.isOffline = true
                self.transactions = transactions
                self.recalculateSum()
                description = (nestedError as? LocalizedError)?.errorDescription ?? "Ошибка сети: данные могут быть неактуальными"
            case BankAccountsServiceError.networkFallback(let account, let nestedError):
                self.appState?.isOffline = true
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
