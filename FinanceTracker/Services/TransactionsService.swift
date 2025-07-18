import Foundation

final class TransactionsService {

    let client = NetworkClient(token: NetworkConstants.token)

    @MainActor
    private lazy var storage: TransactionsStorage = SwiftDataTransactionsStorage()

    @MainActor
    private lazy var backup = SwiftDataBackupStorage()

    private lazy var formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let shared = TransactionsService()

    private init() {}

    // MARK: - Public Methods
    func transactions(from: Date, to: Date) async throws -> [Transaction] {
        do {
            try await syncBackupToServer()
        } catch {
            print("[TransactionsService.transactions] - Failed to sync backup: \(error)")
        }

        do {
            guard var components = URLComponents(string: "\(NetworkConstants.transactionsUrl)/account/119/period") else {
                throw TransactionsServiceError.urlError
            }

            components.queryItems = [
                URLQueryItem(name: "startDate", value: String(from.description.prefix(10))),
                URLQueryItem(name: "endDate", value: String(to.description.prefix(10)))
            ]

            guard let url = components.url else {
                throw NetworkError.invalidResponse
            }

            let transactions = try await client
                .request(url: url, method: .get, responseType: [TransactionResponse].self)
                .map { Transaction(response: $0, with: formatter) }

            try await storage.sync(transactions: transactions)
            return transactions.filter {
                $0.transactionDate >= from && $0.transactionDate <= to
            }//почему

        } catch {
            print("[TransactionsService.transactions] - Fetch failed: \(error)")

            let local = try await storage.transactions().filter {
                $0.transactionDate >= from && $0.transactionDate <= to
            }
            throw TransactionsServiceError.networkFallback(local, error)
        }
    }

    func add(_ transaction: Transaction) async throws {
        guard let url = URL(string: NetworkConstants.transactionsUrl) else {
            throw TransactionsServiceError.urlError
        }

        let short = try await client.request(url: url, method: .post, requestBody: TransactionRequest(from: transaction,with: formatter), responseType: TransactionShortResponse.self)
        let local = short.updated(transaction: transaction, with: formatter)
        try await storage.add(local)
    }

    func update(withId id: Int, with transaction: Transaction) async throws {
        guard let url = URL(string: "\(NetworkConstants.transactionsUrl)/\(id)") else {
            throw TransactionsServiceError.urlError
        }

        let updated = try await client.request(url: url, method: .put, requestBody: TransactionRequest(from: transaction,with: formatter), responseType: TransactionResponse.self)
        try await storage.update(.init(response: updated, with: formatter))
    }

    func delete(withId id: Int) async throws {
        guard let url = URL(string: "\(NetworkConstants.transactionsUrl)/\(id)") else {
            throw TransactionsServiceError.urlError
        }

        let _ = try await client.request(url: url, method: .delete)
        try await storage.delete(id: id)
    }

    func syncBackupToServer() async throws {
        let pendingTransactions = try await backup.pendingTransactions()
        var syncedIDs: [Int] = []
        print(pendingTransactions)
        for pending in pendingTransactions {
            do {
                switch pending.operation {
                case .add:
                    try await add(pending.transaction)
                case .delete:
                    try await update(withId: pending.transaction.id, with: pending.transaction)
                case .update:
                    try await delete(withId: pending.transaction.id)
                }
                syncedIDs.append(pending.id)
            } catch {
                print("[TransactionsService.syncBackupToServer] - Failed to sync pending transaction with id \(pending.id): \(error)")
            }
        }

        for id in syncedIDs {
            try await backup.delete(id: id)
        }
    }
}


