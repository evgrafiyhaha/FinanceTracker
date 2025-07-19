import Foundation

enum BankAccountsServiceError: LocalizedError {
    case notFound
    case urlError
    case networkFallback(BankAccount,Error)

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Счёт не найден"
        case .urlError:
            return "Неверный адрес запроса"
        case .networkFallback(_, let error):
            return (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка"
        }
    }
}
