import Foundation

final class AnalysisPresenter {
    var transactions: [Transaction] = []
    var view: AnalysisViewProtocol?
    var sortingType: SortingType = .none

    init(direction: Direction) {
        self.direction = direction
    }
    // MARK: - Private Properties
    private let direction: Direction
    private let transactionsService = TransactionsService()
    private(set) var sum: Decimal = 0

    var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date() {
        didSet {
            if startDate > endDate {
                endDate = startDate
            }
        }
    }
    var endDate: Date = Date() {
        didSet {
            if startDate > endDate {
                startDate = endDate
            }
        }
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
                self.applySort()
                self.recalculateSum()
                self.view?.reloadTransactionTableView()
                self.view?.reloadPickerTableView()

            }
        } catch {
            print("[AnalysisPresenter.fetchTransactions] - Ошибка загрузки транзакций: \(error)")
        }
    }

    func load() {
        Task {
            await fetchTransactions()
        }
    }

    // MARK: - Private Methods
    private func recalculateSum() {
        sum = transactions.reduce(0) { $0 + $1.amount }
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
}
