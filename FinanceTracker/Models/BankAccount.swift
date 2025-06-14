import Foundation

// MARK: - Model
struct BankAccount {
    let id: Int
    let userId: Int?
    let name: String
    let balance: Decimal
    let currency: Currency
    let createdAt: Date?
    let updatedAt: Date?
}

// MARK: - JSON
extension BankAccount {
    static func parse(jsonObject: Any) -> BankAccount? {
        guard
            let dict = jsonObject as? [String: Any],
            let id = dict["id"] as? Int,
            let name = dict["name"] as? String,
            let balanceString = dict["balance"] as? String,
            let balance = Decimal(string: balanceString),
            let rawCurrency = dict["currency"] as? String,
            let currency = Currency(rawValue: rawCurrency)
        else {
            print("[BankAccount.parse]: Не удалось распарсить аккаунт")
            return nil
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let userId = dict["userId"] as? Int

        let createdAt: Date?
        if let createdAtString = dict["createdAt"] as? String {
            createdAt = formatter.date(from: createdAtString)
        } else {
            createdAt = nil
        }

        let updatedAt: Date?
        if let updatedAtString = dict["updatedAt"] as? String {
            updatedAt = formatter.date(from: updatedAtString)
        } else {
            updatedAt = nil
        }

        return BankAccount(
            id: id,
            userId: userId,
            name: name,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var jsonObject: Any {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var dict: [String: Any] = [
            "id": id,
            "name": name,
            "balance": String(format: "%.2f", NSDecimalNumber(decimal: balance).doubleValue),
            "currency": currency.rawValue
        ]

        if let userId {
            dict["userId"] = userId
        }
        if let createdAt {
            dict["createdAt"] = formatter.string(from: createdAt)
        }
        if let updatedAt {
            dict["updatedAt"] = formatter.string(from: updatedAt)
        }

        return dict
    }
}
