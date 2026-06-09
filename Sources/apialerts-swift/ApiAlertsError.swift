import Foundation

/// Failures from a send, surfaced in the `Result` from ``APIAlerts/sendAsync(_:apiKey:)``.
public enum ApiAlertsError: Error, LocalizedError, Sendable {
    /// `configure` was never called.
    case notConfigured

    /// The API key was empty or whitespace.
    case apiKeyMissing

    /// The event's `message` was empty or whitespace.
    case messageRequired

    /// Transport failure (DNS, TLS, timeout); value is the underlying description.
    case networkError(String)

    /// Non-2xx HTTP status, with the code and message.
    case httpError(Int, String)

    /// The server returned 2xx but the body could not be decoded.
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .notConfigured: return "client not configured"
        case .apiKeyMissing: return "api key is missing"
        case .messageRequired: return "message is required"
        case .networkError(let msg): return msg
        case .httpError(_, let msg): return msg
        case .invalidResponse: return "invalid response from server"
        }
    }
}
