struct PendingTransaction {
    let id: Int
    let operation: BackupTransactionOperation
    let transactionId: Int
    let transaction: Transaction?
}
