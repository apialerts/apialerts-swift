import Foundation

public final class ApiAlertsClient: Sendable {
    private let apiKey: String
    private let debug: Bool
    // nonisolated(unsafe): setOverrides is intended to be called once before concurrent use
    nonisolated(unsafe) private var network: Network

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

    /// Fire-and-forget. Prints critical errors always; HTTP errors/success only when debug is enabled.
    public func send(_ event: Event) async {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fputs("x (apialerts.com) Error: api key is missing\n", stderr)
            return
        }
        guard !event.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fputs("x (apialerts.com) Error: message is required\n", stderr)
            return
        }
        let result = await network.post(apiKey: apiKey, event: event)
        if debug { logResult(result) }
    }

    /// Returns a `Result` — `.success(SendResult)` on delivery, `.failure(ApiAlertsError)` otherwise.
    @discardableResult
    public func sendAsync(_ event: Event) async -> Result<SendResult, ApiAlertsError> {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.apiKeyMissing)
        }
        guard !event.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.messageRequired)
        }
        let result = await network.post(apiKey: apiKey, event: event)
        if debug { logResult(result) }
        return result
    }

    /// Returns a `Result` using an explicit API key override.
    @discardableResult
    public func sendWithKey(_ apiKey: String, event: Event) async -> Result<SendResult, ApiAlertsError> {
        guard !event.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.messageRequired)
        }
        let result = await network.post(apiKey: apiKey, event: event)
        if debug { logResult(result) }
        return result
    }

    private func logResult(_ result: Result<SendResult, ApiAlertsError>) {
        switch result {
        case .success(let r):
            print("✓ (apialerts.com) Alert sent to \(r.workspace) (\(r.channel))")
            for w in r.warnings { print("! (apialerts.com) Warning: \(w)") }
        case .failure(let error):
            fputs("x (apialerts.com) Error: \(error.localizedDescription)\n", stderr)
        }
    }
}
