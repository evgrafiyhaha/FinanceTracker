import Foundation

enum CategoriesServiceError: LocalizedError {
    case urlError

    var errorDescription: String? {
        switch self {
        case .urlError:
            return "Неверный адрес запроса"
        }
    }
}
