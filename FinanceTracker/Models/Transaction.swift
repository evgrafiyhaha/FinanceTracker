import Foundation

// MARK: - Model
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

// MARK: - JSON Parsing
extension Transaction {
    static func parse(jsonObject: Any) -> Transaction? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
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
            let transactionDate = formatter.date(from: transactionDateString),
            let createdAt = formatter.date(from: createdAtString),
            let updatedAt = formatter.date(from: updatedAtString)
        else {
            print("[Transaction.parse]: Не удалось распарсить транзакцию")
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
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dict: [String: Any] = [
            "id": id,
            "account": account.jsonObject,
            "category": category.jsonObject,
            "amount": "\(amount)",
            "transactionDate": formatter.string(from: transactionDate),
            "createdAt": formatter.string(from: createdAt),
            "updatedAt": formatter.string(from: updatedAt),
            "comment": comment ?? NSNull()
        ]
        return dict
    }
}

// MARK: - CSV
extension Transaction {
    enum CSVIndexName: String {
        case id
        case accountId
        case accountName
        case accountBalance
        case accountCurrency
        case categoryId
        case categoryName
        case categoryEmoji
        case isIncome
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }

    static func index(from dict: [String: Int], for key: CSVIndexName) -> Int? {
        return dict[key.rawValue]
    }

    static func parseCSV(fromFileAtPath path: String) -> [Transaction]? {
        guard path.hasSuffix(".csv") else {
            print("[Transaction.parseCSV] - путь не оканчивается на .csv")
            return nil
        }

        guard let data = FileManager.default.contents(atPath: path),
              let content = String(data: data, encoding: .utf8) else {
            print("[Transaction.parseCSV] - не удалось загрузить данные из файла по пути: \(path)")
            return nil
        }

        return parseCSV(content)
    }


    static func parseCSV(_ csv: String) -> [Transaction]? {
        let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else {
            print("[Transaction.parseCSV]: Файл не содержит данных")
            return nil
        }

        let header = lines[0].components(separatedBy: ",")
        let headerIndexMap = Dictionary(uniqueKeysWithValues: header.enumerated().map { ($1, $0) })
        var transactions: [Transaction] = []
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        for line in lines[1...] {
            let parsedLine = line.components(separatedBy: ",")
            guard
                parsedLine.count == header.count,

                let idIndex = index(from: headerIndexMap, for: .id),
                let id = Int(parsedLine[idIndex]),

                let accountIdIndex = index(from: headerIndexMap, for: .accountId),
                let accountId = Int(parsedLine[accountIdIndex]),
                let accountNameIndex = index(from: headerIndexMap, for: .accountName),
                let accountBalanceIndex = index(from: headerIndexMap, for: .accountBalance),
                let accountBalance = Decimal(string: parsedLine[accountBalanceIndex]),
                let accountCurrencyIndex = index(from: headerIndexMap, for: .accountCurrency),
                let accountCurrency = Currency(rawValue: parsedLine[accountCurrencyIndex]),

                let categoryIdIndex = index(from: headerIndexMap, for: .categoryId),
                let categoryId = Int(parsedLine[categoryIdIndex]),
                let categoryNameIndex = index(from: headerIndexMap, for: .categoryName),
                let categoryEmojiIndex = index(from: headerIndexMap, for: .categoryEmoji),
                let isIncomeIndex = index(from: headerIndexMap, for: .isIncome),
                let isIncome = Bool(parsedLine[isIncomeIndex]),

                let amountIndex = index(from: headerIndexMap, for: .amount),
                let amount = Decimal(string: parsedLine[amountIndex]),
                let transactionDateIndex = index(from: headerIndexMap, for: .transactionDate),
                let transactionDate = formatter.date(from: parsedLine[transactionDateIndex]),
                let commentIndex = index(from: headerIndexMap, for: .comment),
                let createdAtIndex = index(from: headerIndexMap, for: .createdAt),
                let createdAt = formatter.date(from: parsedLine[createdAtIndex]),
                let updatedAtIndex = index(from: headerIndexMap, for: .updatedAt),
                let updatedAt = formatter.date(from: parsedLine[updatedAtIndex])
            else { continue }
            let accountName = parsedLine[accountNameIndex]
            let categoryName = parsedLine[categoryNameIndex]
            let categoryEmoji = Character(parsedLine[categoryEmojiIndex])
            let categoryDirection: Direction = isIncome ? .income : .outcome
            let comment = parsedLine[commentIndex].isEmpty ? nil : parsedLine[commentIndex]

            let account = BankAccount(
                id: accountId,
                userId: id,
                name: accountName,
                balance: accountBalance,
                currency: accountCurrency,
                createdAt: nil,
                updatedAt: nil
            )
            let category = Category(
                id: categoryId,
                name: categoryName,
                emoji: categoryEmoji,
                direction: categoryDirection
            )
            let transaction = Transaction(
                id: id,
                account: account,
                category: category,
                amount: amount,
                transactionDate: transactionDate,
                comment: comment,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            transactions.append(transaction)
        }
        
        if transactions.isEmpty {
            print("[Transaction.parseCSV]: Не удалось распарсить ни одной транзакции")
            return nil
        }
        return transactions
    }
}
