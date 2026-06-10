import Foundation
import os

nonisolated(unsafe) private var _sharedClient: ApiAlertsClient?

internal let logger = Logger(subsystem: "com.apialerts.sdk", category: "client")

/// Global API Alerts singleton. Call ``configure(_:debug:session:)`` once, then
/// ``send(_:apiKey:)`` / ``sendAsync(_:apiKey:)`` anywhere. For dependency
/// injection or multiple keys, use ``ApiAlertsClient`` directly instead.
public enum APIAlerts {

    /// Configure the singleton. First call wins; later calls are no-ops.
    ///
    /// - Parameters:
    ///   - apiKey: Workspace API key.
    ///   - debug: Log success and warnings (critical errors always log).
    ///   - session: `URLSession` for delivery; inject one for pooling, proxies, or test mocks.
    public static func configure(_ apiKey: String, debug: Bool = false, session: URLSession = .shared) {
        guard _sharedClient == nil else { return }
        _sharedClient = ApiAlertsClient(apiKey, debug: debug, session: session)
    }

    /// Override the `X-Integration` / `X-Version` headers and base URL. Internal use.
    /// Call after ``configure(_:debug:session:)``.
    public static func setOverrides(integration: String, version: String, baseUrl: String) {
        _sharedClient?.setOverrides(integration: integration, version: version, baseUrl: baseUrl)
    }

    /// Fire-and-forget delivery. Returns immediately; delivery runs in a detached
    /// task. Never throws. `apiKey` overrides the configured key for this call.
    public static func send(_ event: Event, apiKey: String? = nil) {
        guard let client = _sharedClient else {
            logger.error("x (apialerts.com) Error: client not configured")
            return
        }
        client.send(event, apiKey: apiKey)
    }

    /// Awaitable delivery. Never throws; branch on the `Result`. `apiKey` overrides
    /// the configured key for this call.
    @discardableResult
    public static func sendAsync(_ event: Event, apiKey: String? = nil) async -> Result<SendResult, ApiAlertsError> {
        guard let client = _sharedClient else {
            return .failure(.notConfigured)
        }
        return await client.sendAsync(event, apiKey: apiKey)
    }

    internal static func reset() {
        _sharedClient = nil
    }
}
