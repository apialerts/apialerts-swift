import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// A constructable client, for dependency injection or multiple keys in one
/// process. The ``APIAlerts`` singleton wraps a default instance of this.
public final class ApiAlertsClient: ApiAlertsClientProtocol {
    private let apiKey: String
    private let debug: Bool
    // nonisolated(unsafe): setOverrides is meant to be called once before concurrent use
    nonisolated(unsafe) private var network: Network

    /// - Parameters:
    ///   - apiKey: Workspace API key.
    ///   - debug: Log success and warnings (errors always log).
    ///   - session: `URLSession` for delivery; inject one for pooling, proxies, or test mocks.
    public init(_ apiKey: String, debug: Bool = false, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.debug = debug
        self.network = Network(session: session)
    }

    public func setOverrides(integration: String, version: String, baseUrl: String) {
        network.integration = integration
        network.version = version
        network.baseUrl = baseUrl
    }

    /// Fire-and-forget. Returns immediately; delivery runs in a detached task.
    /// Never throws. Logs critical errors always; HTTP errors/success only when debug is enabled.
    public func send(_ event: Event, apiKey: String? = nil) {
        Task {
            let result = await sendAsync(event, apiKey: apiKey)
            // sendAsync already logs everything when debug is on. Otherwise still
            // surface the always-on critical errors (missing key, empty message).
            if !debug, case .failure(let error) = result {
                switch error {
                case .apiKeyMissing, .messageRequired, .notConfigured:
                    logger.error("x (apialerts.com) Error: \(error.localizedDescription)")
                default:
                    break
                }
            }
        }
    }

    /// Returns a `Result`: `.success(SendResult)` on delivery, `.failure(ApiAlertsError)` otherwise.
    @discardableResult
    public func sendAsync(_ event: Event, apiKey: String? = nil) async -> Result<SendResult, ApiAlertsError> {
        let key = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? apiKey! : self.apiKey
        guard !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.apiKeyMissing)
        }
        guard !event.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.messageRequired)
        }
        let result = await network.post(apiKey: key, event: event)
        if debug { logResult(result) }
        return result
    }

    private func logResult(_ result: Result<SendResult, ApiAlertsError>) {
        switch result {
        case .success(let r):
            logger.info("✓ (apialerts.com) Alert sent to \(r.workspace ?? "") (\(r.channel ?? ""))")
            for w in r.warnings { logger.warning("! (apialerts.com) Warning: \(w)") }
        case .failure(let error):
            logger.error("x (apialerts.com) Error: \(error.localizedDescription)")
        }
    }
}
