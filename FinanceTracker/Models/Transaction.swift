import Foundation

struct Transaction {
    let id: Int
    let account: BankAccount
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}

extension Transaction {
    static func parse(jsonObject: Any) -> Transaction? {
        guard
            let dict = jsonObject as? [String: Any],
            let id = dict["id"] as? Int,
            let accountJson = dict["account"],
            let account = BankAccount.parse(jsonObject: accountJson),
            let categoryJson = dict["category"],
            let category = Category.parse(jsonObject: categoryJson),
            let amountString = dict["amount"] as? String,
            let amount = Decimal(string: amountString),
            let transactionDateString = dict["transactionDate"] as? String,
            let createdAtString = dict["createdAt"] as? String,
            let updatedAtString = dict["updatedAt"] as? String,
            let transactionDate = ISO8601DateFormatter().date(from: transactionDateString),
            let createdAt = ISO8601DateFormatter().date(from: createdAtString),
            let updatedAt = ISO8601DateFormatter().date(from: updatedAtString)
        else {
            return nil
        }

        let comment = dict["comment"] as? String

        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var jsonObject: Any {
        let formatter = ISO8601DateFormatter()
        var dict: [String: Any] = [
            "id": id,
            "account": account.jsonObject,
            "category": category.jsonObject,
            "amount": "\(amount)",
            "transactionDate": formatter.string(from: transactionDate),
            "createdAt": formatter.string(from: createdAt),
            "updatedAt": formatter.string(from: updatedAt),
        ]
        if let comment {
            dict["comment"] = comment
        }
        return dict
    }
}

