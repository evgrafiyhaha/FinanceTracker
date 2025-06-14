import XCTest
@testable import FinanceTracker

final class TransactionTests: XCTestCase {

    func test_parse_ReturnsCorrectTransaction() {
        // Given
        let jsonObject: Any = [
            "id": 1,
            "account": [
                "id": 1,
                "name": "Основной счёт",
                "balance": "1000.00",
                "currency": "RUB"
            ],
            "category": [
                "id": 1,
                "name": "Зарплата",
                "emoji": "💰",
                "isIncome": true
            ],
            "amount": "500.00",
            "transactionDate": "2025-06-11T12:33:01.591Z",
            "comment": "Зарплата за месяц",
            "createdAt": "2025-06-11T12:33:01.591Z",
            "updatedAt": "2025-06-11T12:33:01.591Z"
        ]

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let expectedDate = formatter.date(from: "2025-06-11T12:33:01.591Z")
        else {
            XCTFail("Invalid date format")
            return
        }

        // When
        let result = Transaction.parse(jsonObject: jsonObject)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1)

        XCTAssertEqual(result?.account.id, 1)
        XCTAssertEqual(result?.account.name, "Основной счёт")
        XCTAssertEqual(result?.account.balance, 1000.00)
        XCTAssertEqual(result?.account.currency, .rub)

        XCTAssertEqual(result?.category.id, 1)
        XCTAssertEqual(result?.category.name, "Зарплата")
        XCTAssertEqual(result?.category.emoji, "💰")
        XCTAssertEqual(result?.category.direction, .income)

        XCTAssertEqual(result?.amount, 500.00)
        XCTAssertEqual(result?.transactionDate, expectedDate)
        XCTAssertEqual(result?.comment, "Зарплата за месяц")
        XCTAssertEqual(result?.createdAt, expectedDate)
        XCTAssertEqual(result?.updatedAt, expectedDate)
    }

    func test_parse_InvalidData_ReturnsNil() {
        // Given
        let jsonObject: Any = [
            "id": 1,
            "account": [
                "id": 1,
                "name": "Основной счёт",
                "balance": "1000.00",
                "currency": "RUB"
            ],
            "category": [
                "id": 1,
                "name": "Зарплата",
                "emoji": "💰",
                "isIncome": true
            ],
            "amount": "500.00",
            "transactionDate": "2025-06-11T12:33:01.591Z",
            "comment": "Зарплата за месяц",
            "createdAt": "2025-001.591Z",
            "updatedAt": "2025-06-11T12:33:01.591Z"
        ]

        // When
        let result = Transaction.parse(jsonObject: jsonObject)

        // Then
        XCTAssertNil(result)
    }

    func test_jsonObject_ReturnsCorrectJsonObject() {
        // Given
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard
            let createdAt = formatter.date(from: "2025-06-11T12:33:01.591Z"),
            let updatedAt = formatter.date(from: "2025-06-11T12:33:01.591Z"),
            let transactionDate = formatter.date(from: "2025-06-11T12:33:01.591Z")
        else {
            XCTFail("Invalid date format")
            return
        }

        let account = BankAccount(
            id: 1,
            userId: nil,
            name: "Основной счёт",
            balance: 1000.00,
            currency: .rub,
            createdAt: nil,
            updatedAt: nil
        )

        let category = Category(
            id: 1,
            name: "Зарплата",
            emoji: "💰",
            direction: .income
        )

        let transaction = Transaction(
            id: 1,
            account: account,
            category: category,
            amount: 1000.00,
            transactionDate: transactionDate,
            comment: "Зарплата за месяц",
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        // When
        let jsonObject = transaction.jsonObject

        // Then
        guard let json = jsonObject as? [String: Any] else {
            XCTFail("jsonObject is not a [String: Any]")
            return
        }

        XCTAssertEqual(json["id"] as? Int, 1)

        guard let accountJson = json["account"] as? [String: Any] else {
            XCTFail("account is not a [String: Any]")
            return
        }
        XCTAssertEqual(accountJson["id"] as? Int, 1)
        XCTAssertEqual(accountJson["balance"] as? String, "1000.00")
        XCTAssertEqual(accountJson["name"] as? String, "Основной счёт")
        XCTAssertEqual(accountJson["balance"] as? String, "1000.00")
        XCTAssertEqual(accountJson["currency"] as? String, "RUB")

        guard let categoryJson = json["category"] as? [String: Any] else {
            XCTFail("category is not a [String: Any]")
            return
        }
        XCTAssertEqual(categoryJson["id"] as? Int, 1)
        XCTAssertEqual(categoryJson["name"] as? String, "Зарплата")
        XCTAssertEqual(categoryJson["emoji"] as? String, "💰")
        XCTAssertEqual(categoryJson["isIncome"] as? Bool, true)

        XCTAssertEqual(json["transactionDate"] as? String, "2025-06-11T12:33:01.591Z")
        XCTAssertEqual(json["comment"] as? String, "Зарплата за месяц")
        XCTAssertEqual(json["createdAt"] as? String, "2025-06-11T12:33:01.591Z")
        XCTAssertEqual(json["updatedAt"] as? String, "2025-06-11T12:33:01.591Z")
    }

    func test_parseCSV_ReturnsCorrectTransaction() {
        // Given
        let csv = """
        id,accountId,accountName,accountBalance,accountCurrency,categoryId,categoryName,categoryEmoji,isIncome,amount,transactionDate,comment,createdAt,updatedAt
        1,10,Main,1000.0,USD,20,Food,🍔,false,15.00,2025-06-11T12:33:01.591Z,Lunch,2025-06-11T12:33:01.591Z,2025-06-11T12:33:01.591Z
        """

        // When
        let transactions = Transaction.parseCSV(csv)

        // Then
        XCTAssertEqual(transactions?.count, 1)
        XCTAssertEqual(transactions?.first?.id, 1)
        XCTAssertEqual(transactions?.first?.account.name, "Main")
        XCTAssertEqual(transactions?.first?.category.emoji, "🍔")
        XCTAssertEqual(transactions?.first?.amount, 15.00)
    }

    func test_parseCSV_InvalidData_ReturnsNil() {
        // Given
        let invalidCSV = """
        id,accountId,accountName
        1,10
        """

        // When
        let transactions = Transaction.parseCSV(invalidCSV)

        // Then
        XCTAssertNil(transactions)
    }
}
