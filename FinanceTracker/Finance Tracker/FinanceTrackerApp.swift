import SwiftUI

@main
struct FinanceTrackerApp: App {
    init() {
        let csv = """
        id,accountId,accountName,accountBalance,accountCurrency,categoryId,categoryName,categoryEmoji,isIncome,amount,transactionDate,comment,createdAt,updatedAt
        1,101,Main Account,1500.50,USD,5,Groceries,🛒,false,75.30,2025-06-01T14:20:00Z,Food for week,2025-06-01T14:30:00Z,2025-06-01T14:35:00Z
        2,101,Main Account,1500.50,USD,6,Salary,💰,true,2000.00,2025-06-01T10:00:00Z,,2025-06-01T10:05:00Z,2025-06-01T10:06:00Z
        """
        if let transactions = Transaction.parseCSV(csv) {
            for transaction in transactions {
                print("Transaction \(transaction.id): \(transaction.amount) \(transaction.account.currency.rawValue) on \(transaction.transactionDate)")
            }
        } else {
            print("Parsing failed.")
        }
    }
    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
    }
}
