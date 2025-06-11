import SwiftUI

@main
struct FinanceTrackerApp: App {
    init() {
//        let now = Date()
//
//        // 1. BankAccount
//        let originalBA = BankAccount(
//            id: 1,
//            userId: 1,
//            name: "Основной счёт",
//            balance: 1000.00,
//            currency: .rub,
//            createdAt: now,
//            updatedAt: now
//        )
//        let baJson = originalBA.jsonObject
//        if let parsedBA = BankAccount.parse(jsonObject: baJson) {
//            print("✅ BankAccount успешно конвертирован туда и обратно")
//            print(parsedBA)
//        } else {
//            print("❌ Ошибка при парсинге BankAccount")
//        }
//
//        // 2. Category
//        let originalCategory = Category(
//            id: 1,
//            name: "Зарплата",
//            emoji: "🍎",
//            direction: .income
//        )
//        let categoryJson = originalCategory.jsonObject
//        if let parsedCategory = Category.parse(jsonObject: categoryJson) {
//            print("✅ Category успешно конвертирована туда и обратно")
//            print(parsedCategory)
//        } else {
//            print("❌ Ошибка при парсинге Category")
//        }
//
//        // 3. Transaction
//        let originalTransaction = Transaction(
//            id: 1,
//            account: originalBA,
//            category: originalCategory,
//            amount: 1000.00, transactionDate: now,
//            comment: "Перевод зарплаты",
//            createdAt: now,
//            updatedAt: now
//        )
//        let transactionJson = originalTransaction.jsonObject
//        if let parsedTransaction = Transaction.parse(jsonObject: transactionJson) {
//            print("✅ Transaction успешно конвертирована туда и обратно")
//            print(parsedTransaction)
//        } else {
//            print("❌ Ошибка при парсинге Transaction")
//        }
    }
    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
    }
}
