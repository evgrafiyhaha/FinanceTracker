import Foundation
import Combine

enum AccountState {
    case view
    case edit
}

final class AccountViewModel: ObservableObject {

    // MARK: - @Published
    @Published private(set) var balance: Decimal = 0
    @Published var balanceString: String = "0"
    @Published var currency: Currency = .usd
    @Published var state: AccountState = .view
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    // MARK: - Private Properties
    private var account: BankAccount?
    private let accountService = BankAccountsService.shared

    // MARK: - Public Methods
    func updateBalance(from string: String) {
        let normalized = string
            .components(separatedBy: .whitespacesAndNewlines).joined()
            .replacingOccurrences(of: ",", with: ".")
        if let value = Decimal(string: normalized) {
            balanceString = value.formatted()
            balance = value
        } else {
            balanceString = "0"
            balance = 0
        }
    }

    func fetchAccount() async {
        await MainActor.run { isLoading = true; error = nil }
        defer { Task { @MainActor in isLoading = false } }

        do {
            let account = try await accountService.bankAccount()
            await MainActor.run {
                self.account = account
                self.updateBalance(from: account.balance.formatted())
                self.currency = account.currency
            }
        } catch {
            handleError(error, context: "AccountViewModel.fetchAccount")
        }
    }

    func saveChanges() {
        Task {
            await updateOnServer()
        }
    }

    // MARK: - Private Methods
    private func updateOnServer() async {
        await MainActor.run { isLoading = true; error = nil }
        defer { Task { @MainActor in isLoading = false } }

        guard let account else { return }
        do {
            try await accountService.updateBalance(old: account, with: balance, for: currency)
        } catch {
            handleError(error, context: "AccountViewModel.updateOnServer")
        }
    }

    private func handleError(_ error: Error, context: String) {
        Task { @MainActor in
            var description = ""
            switch error {
            case BankAccountsServiceError.networkFallback(let account, let nestedError):
                self.account = account
                self.currency = account.currency
                self.updateBalance(from: account.balance.formatted())
                description = (nestedError as? LocalizedError)?.errorDescription ?? "Ошибка сети: данные могут быть неактуальными"
            default:
                description = (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка"
            }
            self.error = description
            print("[\(context)] - Ошибка: \(error)")
        }
    }
}
