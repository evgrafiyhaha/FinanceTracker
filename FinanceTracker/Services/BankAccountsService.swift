import Foundation

final class BankAccountsService {

    let client = NetworkClient(token: NetworkConstants.token)

    private lazy var formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter
    }()

    static let shared = BankAccountsService()

    private init() {}

    // MARK: - Public Methods
    func bankAccount() async throws -> BankAccount {
        guard let url = URL(string: NetworkConstants.accountsUrl)
        else {
            throw BankAccountsServiceError.urlError
        }
        let accounts = try await client.request(url: url, method: .get, responseType: [BankAccountResponse].self)
        guard let first = accounts.first else {
            throw BankAccountsServiceError.notFound
        }

        let account = BankAccount(response: first, with: formatter)
        return account
    }

    func updateBalance(old account: BankAccount, with value: Decimal, for currency: Currency) async throws {
        let updatedAccount = BankAccount(
            id: account.id,
            userId: account.userId,
            name: account.name,
            balance: value,
            currency: currency,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        try await update(with: updatedAccount)
    }

    // MARK: - Private Methods
    private func update(with account: BankAccount) async throws {
        guard let url = URL(string: "\(NetworkConstants.accountsUrl)/\(account.id)") else {
            throw BankAccountsServiceError.urlError
        }
        let _ = try await client.request(
            url: url,
            method: .put,
            requestBody: BankAccountRequest(from: account),
            responseType: BankAccountResponse.self
        )
    }
}
