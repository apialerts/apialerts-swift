import Foundation

/// The client surface as a protocol, for injecting and mocking. Inject
/// `any ApiAlertsClientProtocol`; use a real ``ApiAlertsClient`` in production
/// and a stub in tests.
public protocol ApiAlertsClientProtocol: Sendable {

    /// Fire-and-forget delivery. `apiKey` overrides the configured key for this call.
    func send(_ event: Event, apiKey: String?) async

    /// Awaitable delivery. `apiKey` overrides the configured key for this call.
    @discardableResult
    func sendAsync(_ event: Event, apiKey: String?) async -> Result<SendResult, ApiAlertsError>

    /// Override the `X-Integration` / `X-Version` headers and base URL. Internal use.
    func setOverrides(integration: String, version: String, baseUrl: String)
}

// Default the optional apiKey; protocol requirements can't carry defaults.
extension ApiAlertsClientProtocol {

    public func send(_ event: Event) async {
        await send(event, apiKey: nil)
    }

    @discardableResult
    public func sendAsync(_ event: Event) async -> Result<SendResult, ApiAlertsError> {
        await sendAsync(event, apiKey: nil)
    }
}
