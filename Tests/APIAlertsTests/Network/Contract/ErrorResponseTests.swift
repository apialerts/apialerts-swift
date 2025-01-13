import XCTest
@testable import APIAlerts

class ErrorResponseTests: XCTestCase {

    func testErrorResponseDecoding() throws {
        let json = """
        {
            "message": "An error occurred"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let errorResponse = try decoder.decode(ErrorResponse.self, from: json)

        XCTAssertEqual(errorResponse.message, "An error occurred")
    }
    
    func testErrorResponseDecodingWithNilValue() throws {
        let json = """
        {
            "message": null
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let errorResponse = try decoder.decode(ErrorResponse.self, from: json)

        XCTAssertNil(errorResponse.message)
    }
    
    func testErrorResponseDecodingWithMissingValue() throws {
        let json = """
        {}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let errorResponse = try decoder.decode(ErrorResponse.self, from: json)

        XCTAssertNil(errorResponse.message)
    }
}
