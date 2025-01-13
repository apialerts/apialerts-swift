import XCTest
@testable import APIAlerts

class HttpMethodTests: XCTestCase {

    func testHttpMethodRawValues() throws {
        XCTAssertEqual(HttpMethod.get.rawValue, "GET")
        XCTAssertEqual(HttpMethod.post.rawValue, "POST")
        XCTAssertEqual(HttpMethod.put.rawValue, "PUT")
        XCTAssertEqual(HttpMethod.delete.rawValue, "DELETE")
    }

    func testHttpMethodCaseCount() throws {
        let allCases = [HttpMethod.get, HttpMethod.post, HttpMethod.put, HttpMethod.delete]
        XCTAssertEqual(allCases.count, 4, "HttpMethod enum should have exactly 4 cases")
    }
}
