import XCTest

@testable import APIAlerts

/// Pins the literal values of SDK constants. Catches accidental changes to
/// the integration name, version shape, base URL, or timeout - matches the
/// canonical pattern documented in SDK Design.
final class ConstantsTests: XCTestCase {

    func testIntegrationName_IsSwift() {
        XCTAssertEqual(integrationName, "swift")
    }

    func testBaseUrl_IsApiAlertsEventEndpoint() {
        XCTAssertEqual(defaultBaseUrl, "https://api.apialerts.com/event")
    }

    func testTimeout_Is30SecondsPerSpec() {
        XCTAssertEqual(timeoutSeconds, 30.0)
    }

    func testVersion_IsOneXSemver() {
        // Major version pin: bumping to v2.x requires updating this test
        // deliberately. Catches accidental major bumps.
        let regex = #"^1\.\d+\.\d+(?:[-+][\w.]+)?$"#
        XCTAssertNotNil(
            integrationVersion.range(of: regex, options: .regularExpression),
            "version \(integrationVersion) does not match 1.x semver"
        )
    }
}
