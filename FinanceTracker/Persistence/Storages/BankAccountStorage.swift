@MainActor
protocol BankAccountStorage {
    func account() async throws -> BankAccount
}
