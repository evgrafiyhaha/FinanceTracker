import Foundation
import Combine

class TransactionsViewModel: ObservableObject {
    let direction: Direction
    private let transactionsService = TransactionsService()
    private let accountService = BankAccountsService()

    @Published var transactions: [Transaction] = [] {
        didSet {
            recalculateSum()
        }
    }

    @Published var sum: Decimal = 0
    @Published var bankAccount: BankAccount?

    init(direction: Direction) {
        self.direction = direction
    }

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
            }
        } catch {
            print("[TransactionsViewModel.fetchTodayTransactions] - Ошибка загрузки транзакций: \(error)")
        }
    }

    func load() {
        Task {
            await fetchTodayTransactions()
            do {
                let account = try await accountService.bankAccount()
                await MainActor.run {
                    self.bankAccount = account
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
