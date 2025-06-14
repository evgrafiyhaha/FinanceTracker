import XCTest
@testable import FinanceTracker

final class BankAccountTests: XCTestCase {

    func test_parse_ReturnsCorrectBankAccount() {
        // Given
        let jsonObject: Any = [
            "id": 1,
            "userId": 2,
            "name": "Заначка",
            "balance": "1000.00",
            "currency": "USD",
            "createdAt": "2025-06-11T12:33:01.591Z",
            "updatedAt": "2025-06-11T12:33:01.591Z"
        ]

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard
            let expectedCreatedAt = formatter.date(from: "2025-06-11T12:33:01.591Z"),
            let expectedUpdatedAt = formatter.date(from: "2025-06-11T12:33:01.591Z")
        else {
            XCTFail("Invalid date format")
            return
        }

        // When
        let result = BankAccount.parse(jsonObject: jsonObject)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1)
        XCTAssertEqual(result?.userId, 2)
        XCTAssertEqual(result?.name, "Заначка")
        XCTAssertEqual(result?.balance, 1000.00)
        XCTAssertEqual(result?.currency, .usd)
        XCTAssertEqual(result?.createdAt, expectedCreatedAt)
        XCTAssertEqual(result?.updatedAt, expectedUpdatedAt)
    }

    func test_parse_InvalidData_ReturnsNil() {
        // Given
        let jsonObject: Any = [
            "userId": 2,
            "name": "Заначка",
            "balance": "1000.00",
            "currency": "USD"
        ]

        // When
        let result = BankAccount.parse(jsonObject: jsonObject)

        // Then
        XCTAssertNil(result)
    }

    func test_jsonObject_ReturnsCorrectJsonObject() {
        // Given
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard
            let createdAt = formatter.date(from: "2025-06-11T12:33:01.591Z"),
            let updatedAt = formatter.date(from: "2025-06-11T12:33:01.591Z")
        else {
            XCTFail("Invalid date format")
            return
        }

        let bankAccount = BankAccount(
            id: 1,
            userId: 2,
            name: "Заначка",
            balance: 1000.00,
            currency: .usd,
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        // When
        let result = bankAccount.jsonObject

        // Then
        guard let json = result as? [String: Any] else {
            XCTFail("jsonObject is not a [String: Any]")
            return
        }

        XCTAssertEqual(json["id"] as? Int, 1)
        XCTAssertEqual(json["userId"] as? Int, 2)
        XCTAssertEqual(json["name"] as? String, "Заначка")
        XCTAssertEqual(json["balance"] as? String, "1000.00")
        XCTAssertEqual(json["currency"] as? String, "USD")
        XCTAssertEqual(json["createdAt"] as? String, formatter.string(from: createdAt))
        XCTAssertEqual(json["updatedAt"] as? String, formatter.string(from: updatedAt))
    }
}
