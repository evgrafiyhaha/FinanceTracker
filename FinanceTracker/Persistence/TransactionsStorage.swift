protocol TransactionsStorage {
    func transactions() async throws -> [Transaction]
    func update(_ transaction: Transaction) async throws
    func delete(id: Int) async throws
    func add(_ transaction: Transaction) async throws
    func sync(transactions: [Transaction]) async throws
}
