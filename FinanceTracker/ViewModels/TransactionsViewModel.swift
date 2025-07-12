import Foundation
import Combine


final class TransactionsViewModel: ObservableObject {

    // MARK: - @Published
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var sum: Decimal = 0
    @Published private(set) var bankAccount: BankAccount?

    // MARK: - Private Properties
    private let direction: Direction
    private let transactionsService = TransactionsService.shared
    private let accountService = BankAccountsService.shared

    // MARK: - init
    init(direction: Direction) {
        self.direction = direction
    }

    // MARK: - Public Methods
    func fetchTodayTransactions() async {
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
                self.transactions = filtered
                self.recalculateSum()
            }
        } catch {
            print("[TransactionsViewModel.fetchTodayTransactions] - Ошибка загрузки транзакций: \(error)")
        }
    }

    func load() async {
        await fetchTodayTransactions()
        do {
            let account = try await accountService.bankAccount()
            await MainActor.run {
                self.bankAccount = account
                self.recalculateSum()
            }
        }
        catch {
            print("[TransactionsViewModel.load] - Ошибка загрузки счета: \(error)")
        }

    }

    // MARK: - Private Methods
    private func recalculateSum() {
        sum = transactions.reduce(0) { $0 + $1.amount }
    }
}
