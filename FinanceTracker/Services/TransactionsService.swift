import Foundation

enum TransactionsServiceError: Error {
    case notFound
    case alreadyExists
    case urlError
}

final class TransactionsService {

    let client = NetworkClient(token: NetworkConstants.token)

    private lazy var formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let shared = TransactionsService()

    private init() {}

    // MARK: - Public Methods
    func transactions(from: Date, to: Date) async throws -> [Transaction] {
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

        return try await client.request(url: url, method: .get, responseType: [TransactionResponse].self).map( {Transaction(response: $0, with: formatter)} )
    }

    func add(_ transaction: Transaction) async throws {
        guard let url = URL(string: NetworkConstants.transactionsUrl) else {
            throw TransactionsServiceError.urlError
        }

        let _ = try await client.request(url: url, method: .post, requestBody: TransactionRequest(from: transaction,with: formatter), responseType: TransactionShortResponse.self)
    }

    func update(withId id: Int, with transaction: Transaction) async throws {
        guard let url = URL(string: "\(NetworkConstants.transactionsUrl)/\(id)") else {
            throw TransactionsServiceError.urlError
        }

        let _ = try await client.request(url: url, method: .put, requestBody: TransactionRequest(from: transaction,with: formatter), responseType: TransactionResponse.self)
    }

    func delete(withId id: Int) async throws {
        guard let url = URL(string: "\(NetworkConstants.transactionsUrl)/\(id)") else {
            throw TransactionsServiceError.urlError
        }

        let _ = try await client.request(url: url, method: .delete)
    }
}

