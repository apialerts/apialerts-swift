import XCTest
@testable import APIAlerts

class EventResponseTests: XCTestCase {

    func testEventResponseDecoding() throws {
        let json = """
        {
            "workspace": "test-workspace",
            "channel": "test-channel",
            "remainingQuota": 100,
            "errors": ["Error 1", "Error 2"]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let eventResponse = try decoder.decode(EventResponse.self, from: json)

        XCTAssertEqual(eventResponse.workspace, "test-workspace")
        XCTAssertEqual(eventResponse.channel, "test-channel")
        XCTAssertEqual(eventResponse.remainingQuota, 100)
        XCTAssertEqual(eventResponse.errors, ["Error 1", "Error 2"])
    }

    func testEventResponseDecodingWithNilValues() throws {
        let json = """
        {
            "workspace": null,
            "channel": null,
            "remainingQuota": null,
            "errors": null
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let eventResponse = try decoder.decode(EventResponse.self, from: json)

        XCTAssertNil(eventResponse.workspace)
        XCTAssertNil(eventResponse.channel)
        XCTAssertNil(eventResponse.remainingQuota)
        XCTAssertNil(eventResponse.errors)
    }
}
