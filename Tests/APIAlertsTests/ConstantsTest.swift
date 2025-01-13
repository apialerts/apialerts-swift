import XCTest
@testable import APIAlerts

class ConstantsTests: XCTestCase {

    func testConstants() throws {
        XCTAssertEqual(API_URL, "https://api.apialerts.com")
        XCTAssertEqual(INTEGRATION_NAME, "swift")
    }
}
