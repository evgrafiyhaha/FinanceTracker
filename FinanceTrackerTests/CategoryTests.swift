import XCTest
@testable import FinanceTracker

final class CategoryTests: XCTestCase {

    func test_parse_ReturnsCorrectCategory() {
        // Given
        let jsonObject: Any = [
            "id": 1,
            "name": "Зарплата",
            "emoji": "💰",
            "isIncome": true,
        ]

        // When
        let result = Category.parse(jsonObject: jsonObject)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1)
        XCTAssertEqual(result?.name, "Зарплата")
        XCTAssertEqual(result?.emoji, "💰")
        XCTAssertEqual(result?.direction, .income)
    }

    func test_parse_InvalidData_ReturnsNil() {
        // Given
        let jsonObject: Any = [
            "name": "Зарплата",
            "emoji": "💰",
            "isIncome": true,
        ]

        // When
        let result = Category.parse(jsonObject: jsonObject)

        // Then
        XCTAssertNil(result)
    }

    func test_jsonObject_ReturnsCorrectJsonObject() {
        // Given
        let category = Category(id: 0, name: "Зарплата", emoji: "💰", direction: .income)

        // When
        let result = category.jsonObject

        // Then
        guard let json = result as? [String: Any] else {
            XCTFail("jsonObject is not a [String: Any]")
            return
        }

        XCTAssertEqual(json["id"] as? Int, 0)
        XCTAssertEqual(json["name"] as? String, "Зарплата")
        XCTAssertEqual(json["emoji"] as? String, "💰")
        XCTAssertEqual(json["isIncome"] as? Bool, true)
    }
}
