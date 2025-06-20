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

class TransactionHistoryViewModel: ObservableObject {

    // MARK: - @Published
    @Published var transactions: [Transaction] = []
    @Published var sortingType: SortingType = .none
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

    // MARK: - Private Properties
    private let direction: Direction
    private let transactionsService = TransactionsService()
    private let accountService = BankAccountsService()

    // MARK: - init
    init(direction: Direction) {
        self.direction = direction
    }

    // MARK: - Public Methods
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
                self.applySort()
                self.recalculateSum()
            }
        } catch {
            print("[TransactionHistoryViewModel.fetchTransactions] - Ошибка загрузки транзакций: \(error)")
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
                print("[TransactionHistoryViewModel.load] - Ошибка загрузки счета: \(error)")
            }
        }
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

    // MARK: - Private Methods
    private func recalculateSum() {
        sum = transactions.reduce(0) { $0 + $1.amount }
    }
}
