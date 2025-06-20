import Foundation
import Combine

class TransactionHistoryViewModel: ObservableObject {
    let direction: Direction
    private let transactionsService = TransactionsService()
    private let accountService = BankAccountsService()

    @Published var transactions: [Transaction] = []

    @Published var sum: Decimal = 0
    @Published var bankAccount: BankAccount?
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

    init(direction: Direction) {
        self.direction = direction
    }

    func fetchTransactions() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) else {
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
            print("[TransactionsViewModel.fetchTransactions] - Ошибка загрузки транзакций: \(error)")
        }
    }

    func load() {
        Task {
            await fetchTransactions()
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
    }

    private func recalculateSum() {
        sum = transactions.reduce(0) { $0 + $1.amount }
    }
}
