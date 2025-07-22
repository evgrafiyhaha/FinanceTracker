import Foundation

enum CategoriesServiceError: LocalizedError {
    case urlError
    case networkFallback([Category],Error)

    var errorDescription: String? {
        switch self {
        case .urlError:
            return "Неверный адрес запроса"
        case .networkFallback(_, let error):
            return (error as? LocalizedError)?.errorDescription ?? "Неизвестная ошибка"
        }
    }
}
