import Foundation

final class CategoriesService {

    private let client = NetworkClient(token: NetworkConstants.token)

    @MainActor
    private lazy var storage = SwiftDataCategoriesStorage()

    @MainActor
    private lazy var backup = SwiftDataBackupStorage()

    // MARK: - Public Methods
    func categories() async throws -> [Category] {
        do {
            guard let categoriesURL = URL(string: NetworkConstants.categoriesUrl) else {
                throw CategoriesServiceError.urlError
            }
            let categs = try await client.request(url: categoriesURL, method: .get, responseType: [CategoryResponse].self)
                .map( { Category(response: $0) } )
            try await storage.sync(categories: categs)
            return categs
        } catch {
            print("[CategoriesService.categories] - Fetch failed: \(error)")
            let local = try await storage.categories()
            throw CategoriesServiceError.networkFallback(local, error)
        }
    }

    func categories(withDirection direction: Direction) async throws -> [Category] {
        do {
            let all = try await categories()
            return all.filter { $0.direction == direction }
        } catch CategoriesServiceError.networkFallback(let local, let error) {
            let filtered = local.filter { $0.direction == direction }
            throw CategoriesServiceError.networkFallback(filtered, error)
        } catch {
            print("[CategoriesService.categories(withDirection)] - Fallback: \(error)")
            let local = try await storage.categories()
            let filtered = local.filter { $0.direction == direction }
            throw CategoriesServiceError.networkFallback(filtered, error)
        }
    }
}
