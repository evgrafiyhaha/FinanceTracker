import SwiftData
import Foundation

@MainActor
final class SwiftDataBankAccountStorage {
    private let context: ModelContext = SwiftDataStorage.shared.context

    func account() async throws -> BankAccount {
        try context.fetch(FetchDescriptor<BankAccountModel>())
            .map { $0.toDomain() }.first!
    }
}
