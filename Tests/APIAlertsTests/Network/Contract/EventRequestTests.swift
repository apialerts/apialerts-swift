import XCTest
@testable import APIAlerts

class EventRequestTests: XCTestCase {

    func testEventRequestEncoding() throws {
        let eventRequest = EventRequest(channel: "test-channel", message: "Test Message", tags: ["tag1", "tag2"], link: "https://apialerts.com")
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(eventRequest)
        
        let decoder = JSONDecoder()
        let decodedEventRequest = try decoder.decode(EventRequest.self, from: jsonData)
        
        XCTAssertEqual(decodedEventRequest.channel, "test-channel")
        XCTAssertEqual(decodedEventRequest.message, "Test Message")
        XCTAssertEqual(decodedEventRequest.tags, ["tag1", "tag2"])
        XCTAssertEqual(decodedEventRequest.link, "https://apialerts.com")
    }

    func testEventRequestDecoding() throws {
        let json = """
        {
            "channel": "test-channel",
            "message": "Test Message",
            "tags": ["tag1", "tag2"],
            "link": "https://apialerts.com"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let eventRequest = try decoder.decode(EventRequest.self, from: json)

        XCTAssertEqual(eventRequest.channel, "test-channel")
        XCTAssertEqual(eventRequest.message, "Test Message")
        XCTAssertEqual(eventRequest.tags, ["tag1", "tag2"])
        XCTAssertEqual(eventRequest.link, "https://apialerts.com")
    }

    func testEventRequestDecodingWithNilValues() throws {
        let json = """
        {
            "channel": null,
            "message": "Test Message",
            "tags": null,
            "link": null
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let eventRequest = try decoder.decode(EventRequest.self, from: json)

        XCTAssertNil(eventRequest.channel)
        XCTAssertEqual(eventRequest.message, "Test Message")
        XCTAssertNil(eventRequest.tags)
        XCTAssertNil(eventRequest.link)
    }
}
