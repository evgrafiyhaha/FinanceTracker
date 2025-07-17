import Foundation

enum TransactionsServiceError: LocalizedError {
    case notFound
    case urlError

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Операция не найдена"
        case .urlError:
            return "Неверный адрес запроса"
        }
    }
}
