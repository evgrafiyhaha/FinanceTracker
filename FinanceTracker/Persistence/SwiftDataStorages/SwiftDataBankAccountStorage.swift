import SwiftData
import Foundation

@MainActor
final class SwiftDataBankAccountStorage: BankAccountStorage {

    // MARK: - Private Properties
    private let context: ModelContext = SwiftDataStorage.shared.context

    // MARK: - Public Methods
    func account() async throws -> BankAccount {
        try context.fetch(FetchDescriptor<BankAccountModel>())
            .map { $0.toDomain() }.first!
    }

    func sync(account: BankAccount) async throws {
        let accountId = account.id
        let accountFetch = FetchDescriptor<BankAccountModel>(
            predicate: #Predicate { $0.id == accountId }
        )
        let accountModel = try context.fetch(accountFetch).first ?? {
            let newAccount = BankAccountModel(from: account)
            context.insert(newAccount)
            return newAccount
        }()
        accountModel.balance = account.balance
        accountModel.currency = account.currency.rawValue
        accountModel.updatedAt = account.updatedAt
        try context.save()
    }
}
