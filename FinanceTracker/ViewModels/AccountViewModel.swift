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
        do {
            let account = try await accountService.bankAccount()
            await MainActor.run {
                self.account = account
                self.updateBalance(from: account.balance.formatted())
                self.currency = account.currency
            }
        }
        catch {
            print("[AccountViewModel.fetchAccount] - Ошибка загрузки счета: \(error)")
        }
    }

    func saveChanges() {
        Task {
            await updateOnServer()
        }
    }

    private func updateOnServer() async {
        guard let account else { return }
        do {
            try await accountService.updateBalance(old: account, with: balance, for: currency)
        } catch {
            print("[AccountViewModel.updateBalanceOnServer] - Ошибка обновления баланса: \(error)")
        }
    }
}
