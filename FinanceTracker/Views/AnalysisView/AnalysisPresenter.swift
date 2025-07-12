import Foundation

protocol AnalysisPresenterProtocol: AnyObject {
    var view: AnalysisViewProtocol? { get set }
    var startDate: Date { get set }
    var endDate: Date { get set }
    var sortingType: SortingType { get set }
    var transactions: [Transaction] { get }
    var bankAccount: BankAccount? { get }
    var sum: Decimal { get }
    var direction: Direction { get }
    func load()

}

final class AnalysisPresenter: AnalysisPresenterProtocol {

    // MARK: - Private Properties
    weak var view: AnalysisViewProtocol?

    var transactions: [Transaction] = []
    var sortingType: SortingType = .none
    let direction: Direction

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

    // MARK: - Private Properties
    private(set) var sum: Decimal = 0
    private(set) var bankAccount: BankAccount?
    private let transactionsService = TransactionsService.shared
    private let accountService = BankAccountsService.shared

    // MARK: - Init
    init(direction: Direction) {
        self.direction = direction
    }

    // MARK: - Public Methods
    func load() {
        Task {
            await fetchTransactions()
            do {
                let account = try await accountService.bankAccount()
                await MainActor.run {
                    self.bankAccount = account
                    self.recalculateSum()
                    self.view?.reloadPickerTableView()
                }
            }
            catch {
                print("[AnalysisPresenter.load] - Ошибка загрузки счета: \(error)")
            }
        }
    }

    // MARK: - Private Methods
    private func fetchTransactions() async {
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

    private func recalculateSum() {
        sum = transactions.reduce(0) { $0 + $1.amount }
    }

    private func applySort() {
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
