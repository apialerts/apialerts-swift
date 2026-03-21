import XCTest
import Foundation
@testable import APIAlerts

// MARK: - Mock URLProtocol

final class MockURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (Int, String))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (statusCode, body) = try handler(request)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: Data(body.utf8))
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Helpers

private let successBody = #"{"workspace":"My Workspace","channel":"general","warnings":[]}"#

private func mockSession(statusCode: Int, body: String = "") -> URLSession {
    MockURLProtocol.handler = { _ in (statusCode, body) }
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}

private func successSession(
    workspace: String = "My Workspace",
    channel: String = "general",
    warnings: [String] = []
) -> URLSession {
    let w = warnings.map { "\"\($0)\"" }.joined(separator: ",")
    return mockSession(statusCode: 200, body: """
    {"workspace":"\(workspace)","channel":"\(channel)","warnings":[\(w)]}
    """)
}

private func captureSession(statusCode: Int = 200, body: String = successBody) -> (URLSession, () -> URLRequest?) {
    var captured: URLRequest?
    MockURLProtocol.handler = { req in
        captured = req
        return (statusCode, body)
    }
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)
    return (session, { captured })
}

private func captureBodySession() -> (URLSession, () -> Data?) {
    var capturedBody: Data?
    MockURLProtocol.handler = { req in
        // URLSession sends body as httpBodyStream
        if let stream = req.httpBodyStream {
            stream.open()
            var data = Data()
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
            while stream.hasBytesAvailable {
                let n = stream.read(buffer, maxLength: 4096)
                if n > 0 { data.append(buffer, count: n) }
            }
            buffer.deallocate()
            stream.close()
            capturedBody = data
        } else {
            capturedBody = req.httpBody
        }
        return (200, successBody)
    }
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)
    return (session, { capturedBody })
}

// MARK: - Result helpers

private func assertSuccess<E: Error>(_ result: Result<SendResult, E>, file: StaticString = #file, line: UInt = #line) -> SendResult? {
    guard case .success(let sent) = result else {
        XCTFail("Expected success but got failure", file: file, line: line)
        return nil
    }
    return sent
}

private func assertFailure<E: Error>(_ result: Result<SendResult, E>, file: StaticString = #file, line: UInt = #line) -> E? {
    guard case .failure(let error) = result else {
        XCTFail("Expected failure but got success", file: file, line: line)
        return nil
    }
    return error
}

// MARK: - Tests

final class ClientTests: XCTestCase {

    override func tearDown() {
        APIAlerts.reset()
    }

    // ── Validation ────────────────────────────────────────────────────────────

    func testEmptyApiKey_ReturnsError() async {
        let client = ApiAlertsClient("", session: successSession())
        let result = await client.sendAsync(Event(message: "test"))
        let error = assertFailure(result)
        XCTAssertEqual(error?.localizedDescription, "api key is missing")
    }

    func testWhitespaceApiKey_ReturnsError() async {
        let client = ApiAlertsClient("   ", session: successSession())
        let result = await client.sendAsync(Event(message: "test"))
        let error = assertFailure(result)
        XCTAssertEqual(error?.localizedDescription, "api key is missing")
    }

    func testEmptyMessage_ReturnsError() async {
        let client = ApiAlertsClient("key", session: successSession())
        let result = await client.sendAsync(Event(message: ""))
        let error = assertFailure(result)
        XCTAssertEqual(error?.localizedDescription, "message is required")
    }

    // ── HTTP status codes ─────────────────────────────────────────────────────

    func testSendAsync_Returns_SendResult_On200() async {
        let client = ApiAlertsClient("key", session: successSession(workspace: "W", channel: "C"))
        let result = await client.sendAsync(Event(message: "test"))
        let sent = assertSuccess(result)
        XCTAssertEqual(sent?.workspace, "W")
        XCTAssertEqual(sent?.channel, "C")
        XCTAssertTrue(sent?.warnings.isEmpty ?? false)
    }

    func testSendAsync_Returns_Warnings_On200() async {
        let client = ApiAlertsClient("key", session: successSession(warnings: ["deprecated"]))
        let result = await client.sendAsync(Event(message: "test"))
        let sent = assertSuccess(result)
        XCTAssertEqual(sent?.warnings, ["deprecated"])
    }

    func testSendAsync_Returns_Error_On400() async {
        let client = ApiAlertsClient("key", session: mockSession(statusCode: 400))
        let result = await client.sendAsync(Event(message: "test"))
        let error = assertFailure(result)
        XCTAssertEqual(error?.localizedDescription, "bad request")
    }

    func testSendAsync_Returns_Error_On401() async {
        let client = ApiAlertsClient("key", session: mockSession(statusCode: 401))
        let result = await client.sendAsync(Event(message: "test"))
        let error = assertFailure(result)
        XCTAssertEqual(error?.localizedDescription, "unauthorized — check your api key")
    }

    func testSendAsync_Returns_Error_On403() async {
        let client = ApiAlertsClient("key", session: mockSession(statusCode: 403))
        let result = await client.sendAsync(Event(message: "test"))
        let error = assertFailure(result)
        XCTAssertEqual(error?.localizedDescription, "forbidden")
    }

    func testSendAsync_Returns_Error_On429() async {
        let client = ApiAlertsClient("key", session: mockSession(statusCode: 429))
        let result = await client.sendAsync(Event(message: "test"))
        let error = assertFailure(result)
        XCTAssertEqual(error?.localizedDescription, "rate limit exceeded")
    }

    func testSendAsync_Returns_Error_On500() async {
        let client = ApiAlertsClient("key", session: mockSession(statusCode: 500))
        let result = await client.sendAsync(Event(message: "test"))
        let error = assertFailure(result)
        XCTAssertEqual(error?.localizedDescription, "unexpected status: 500")
    }

    func testSendAsync_Returns_Error_OnBadJson() async {
        let client = ApiAlertsClient("key", session: mockSession(statusCode: 200, body: "not json"))
        let result = await client.sendAsync(Event(message: "test"))
        let error = assertFailure(result)
        XCTAssertEqual(error?.localizedDescription, "invalid response from server")
    }

    // ── Request headers ───────────────────────────────────────────────────────

    func testSendAsync_Sends_AuthorizationHeader() async {
        let (session, getRequest) = captureSession()
        let client = ApiAlertsClient("my-api-key", session: session)
        _ = await client.sendAsync(Event(message: "test"))
        XCTAssertEqual(getRequest()?.value(forHTTPHeaderField: "Authorization"), "Bearer my-api-key")
    }

    func testSendAsync_Sends_IntegrationHeaders() async {
        let (session, getRequest) = captureSession()
        let client = ApiAlertsClient("key", session: session)
        _ = await client.sendAsync(Event(message: "test"))
        XCTAssertEqual(getRequest()?.value(forHTTPHeaderField: "X-Integration"), "swift")
        XCTAssertEqual(getRequest()?.value(forHTTPHeaderField: "X-Version"), "2.0.0")
    }

    func testSetOverrides_Changes_IntegrationHeaders() async {
        let (session, getRequest) = captureSession()
        let client = ApiAlertsClient("key", session: session)
        client.setOverrides(integration: "github-actions", version: "1.0.0", baseUrl: "http://localhost")
        _ = await client.sendAsync(Event(message: "test"))
        XCTAssertEqual(getRequest()?.value(forHTTPHeaderField: "X-Integration"), "github-actions")
        XCTAssertEqual(getRequest()?.value(forHTTPHeaderField: "X-Version"), "1.0.0")
    }

    func testSendWithKey_Uses_ProvidedApiKey() async {
        let (session, getRequest) = captureSession()
        let client = ApiAlertsClient("original-key", session: session)
        _ = await client.sendWithKey("override-key", event: Event(message: "test"))
        XCTAssertEqual(getRequest()?.value(forHTTPHeaderField: "Authorization"), "Bearer override-key")
    }

    // ── Payload serialization ─────────────────────────────────────────────────

    func testSendAsync_Serializes_AllFields() async throws {
        let (session, getBody) = captureBodySession()
        let client = ApiAlertsClient("key", session: session)
        _ = await client.sendAsync(Event(
            message: "Full payload",
            channel: "developer",
            event: "ci.deploy",
            title: "Deployed",
            tags: ["CI/CD", "Swift"],
            link: "https://github.com"
        ))
        let body = try XCTUnwrap(getBody())
        let json = try JSONSerialization.jsonObject(with: body) as! [String: Any]
        XCTAssertEqual(json["message"] as? String, "Full payload")
        XCTAssertEqual(json["channel"] as? String, "developer")
        XCTAssertEqual(json["event"] as? String, "ci.deploy")
        XCTAssertEqual(json["title"] as? String, "Deployed")
        XCTAssertEqual(json["link"] as? String, "https://github.com")
    }

    func testSendAsync_Omits_NullFields() async throws {
        let (session, getBody) = captureBodySession()
        let client = ApiAlertsClient("key", session: session)
        _ = await client.sendAsync(Event(message: "minimal"))
        let body = try XCTUnwrap(getBody())
        let json = try JSONSerialization.jsonObject(with: body) as! [String: Any]
        XCTAssertNil(json["channel"])
        XCTAssertNil(json["event"])
        XCTAssertNil(json["title"])
        XCTAssertNil(json["tags"])
        XCTAssertNil(json["link"])
        XCTAssertNil(json["data"])
    }

    // ── Fire-and-forget ───────────────────────────────────────────────────────

    func testSend_DoesNotCrash_OnError() async {
        let client = ApiAlertsClient("key", session: mockSession(statusCode: 401))
        await client.send(Event(message: "test")) // should not crash
    }

    // ── Global singleton ──────────────────────────────────────────────────────

    func testAPIAlerts_SendAsync_Returns_NotConfigured_BeforeConfigure() async {
        let result = await APIAlerts.sendAsync(Event(message: "test"))
        let error = assertFailure(result)
        XCTAssertEqual(error?.localizedDescription, "client not configured")
    }

    func testAPIAlerts_Configure_InitializesClient() async {
        APIAlerts.configure("key", session: successSession(workspace: "W", channel: "C"))
        let result = await APIAlerts.sendAsync(Event(message: "test"))
        let sent = assertSuccess(result)
        XCTAssertEqual(sent?.workspace, "W")
    }

    func testAPIAlerts_Configure_IsIdempotent() async {
        APIAlerts.configure("first-key", session: successSession())
        APIAlerts.configure("second-key") // should be ignored
        _ = await APIAlerts.sendAsync(Event(message: "test")) // should not crash
    }

    func testAPIAlerts_Send_IsNoOp_BeforeConfigure() async {
        await APIAlerts.send(Event(message: "test")) // should not crash
    }
}
