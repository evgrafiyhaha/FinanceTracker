@MainActor
protocol BankAccountStorage {
    func account() async throws -> BankAccount
    func sync(account: BankAccount) async throws
}
