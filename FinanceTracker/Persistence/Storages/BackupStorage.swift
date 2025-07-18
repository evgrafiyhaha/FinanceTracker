@MainActor
protocol BackupStorage {
    func pendingTransactions() async throws -> [PendingTransaction]
    func delete(id: Int) async throws
    func add(transaction: Transaction?, transactionId: Int?, for operation: BackupOperation) async throws
}
