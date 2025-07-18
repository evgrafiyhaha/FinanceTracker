struct PendingTransaction {
    let id: Int
    let operation: BackupOperation
    let transactionId: Int
    let transaction: Transaction?
}
