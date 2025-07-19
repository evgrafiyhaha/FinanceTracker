import Foundation

enum TransactionsServiceError: LocalizedError {
    case notFound
    case urlError
    case networkFallback([Transaction],Error)

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Операция не найдена"
        case .urlError:
            return "Неверный адрес запроса"
        case .networkFallback(_, let error):
            return (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка"
        }
    }
}
