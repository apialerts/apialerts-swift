import Foundation

/// Errors that can be returned by the API Alerts SDK.
public enum ApiAlertsError: Error, LocalizedError, Sendable {
    case notConfigured
    case apiKeyMissing
    case messageRequired
    case networkError(String)
    case httpError(Int, String)
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .notConfigured:           return "client not configured"
        case .apiKeyMissing:           return "api key is missing"
        case .messageRequired:         return "message is required"
        case .networkError(let msg):   return msg
        case .httpError(_, let msg):   return msg
        case .invalidResponse:         return "invalid response from server"
        }
    }
}
