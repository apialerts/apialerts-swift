import Foundation

nonisolated(unsafe) private var _sharedClient: ApiAlertsClient?

public enum APIAlerts {

    /// Call once at startup. Subsequent calls are no-ops.
    public static func configure(_ apiKey: String, debug: Bool = false, session: URLSession = .shared) {
        guard _sharedClient == nil else { return }
        _sharedClient = ApiAlertsClient(apiKey, debug: debug, session: session)
    }

    public static func setOverrides(integration: String, version: String, baseUrl: String) {
        _sharedClient?.setOverrides(integration: integration, version: version, baseUrl: baseUrl)
    }

    /// Fire-and-forget. Logs "client not configured" to stderr if configure() was not called first.
    public static func send(_ event: Event) async {
        guard let client = _sharedClient else {
            fputs("x (apialerts.com) Error: client not configured\n", stderr)
            return
        }
        await client.send(event)
    }

    /// Never throws. Returns SendResult with success: false if not configured or on any error.
    @discardableResult
    public static func sendAsync(_ event: Event) async -> SendResult {
        guard let client = _sharedClient else {
            return SendResult(success: false, workspace: nil, channel: nil, warnings: [], error: "client not configured")
        }
        return await client.sendAsync(event)
    }

    internal static func reset() {
        _sharedClient = nil
    }
}
