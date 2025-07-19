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
            await MainActor.run { view?.showLoader() }

            var errorDescription: String?

            do {
                try await fetchTransactions()
            } catch let TransactionsServiceError.networkFallback(transactions, nestedError) {
                self.transactions = transactions
                self.recalculateSum()
                await MainActor.run {
                    self.view?.reloadTransactionTableView()
                    self.view?.reloadPickerTableView()
                }
                errorDescription = (nestedError as? LocalizedError)?.errorDescription ?? "Ошибка сети при загрузке операций. Данные могут быть неактуальны."
            } catch {
                errorDescription = (error as? LocalizedError)?.errorDescription ?? "Не удалось загрузить операции"
            }

            do {
                let account = try await accountService.bankAccount()
                self.bankAccount = account
                self.recalculateSum()
                await MainActor.run {
                    self.view?.reloadPickerTableView()
                }
            } catch let BankAccountsServiceError.networkFallback(account, nestedError) {
                self.bankAccount = account
                self.recalculateSum()
                await MainActor.run {
                    self.view?.reloadPickerTableView()
                }
                errorDescription = (nestedError as? LocalizedError)?.errorDescription ?? "Ошибка сети при загрузке счёта. Данные могут быть неактуальны."
            } catch {
                errorDescription = (error as? LocalizedError)?.errorDescription ?? "Не удалось загрузить счёт"
            }

            guard let errorDescription else {
                await MainActor.run {
                    view?.hideLoader()
                }
                return
            }
            await MainActor.run {
                self.view?.hideLoader()
                self.view?.showError(errorDescription)
            }
        }
    }

    // MARK: - Private Methods
    private func fetchTransactions() async throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) else { return }

        let all = try await transactionsService.transactions(from: startOfDay, to: endOfDay)
        let filtered = all.filter { $0.category.direction == direction }

        await MainActor.run {
            self.transactions = filtered
            self.applySort()
            self.recalculateSum()
            self.view?.reloadTransactionTableView()
            self.view?.reloadPickerTableView()
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
