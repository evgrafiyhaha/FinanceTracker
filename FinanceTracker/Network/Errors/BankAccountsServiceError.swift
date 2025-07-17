import Foundation

enum BankAccountsServiceError: LocalizedError {
    case notFound
    case urlError

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Счёт не найден"
        case .urlError:
            return "Неверный адрес запроса"
        }
    }
}
