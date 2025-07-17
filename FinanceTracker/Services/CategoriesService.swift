import Foundation

final class CategoriesService {

    private let client = NetworkClient(token: NetworkConstants.token)

    // MARK: - Public Methods
    func categories() async throws -> [Category] {
        guard let categoriesURL = URL(string: NetworkConstants.categoriesUrl) else {
            throw CategoriesServiceError.urlError
        }
        let categs = try await client.request(url: categoriesURL, method: .get, responseType: [CategoryResponse].self)
        return categs.map( { Category(response: $0) } )
    }

    func categories(withDirection direction: Direction) async throws -> [Category] {
        let all = try await categories()
        return all.filter { $0.direction == direction }
    }
}
