import Combine
import Foundation

final class AppState: ObservableObject {
    @Published var isOffline: Bool = false
}
