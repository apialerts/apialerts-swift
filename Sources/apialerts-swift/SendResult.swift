import Foundation

/// A successful delivery. Failures come back as ``ApiAlertsError`` in the `Result`.
public struct SendResult: Sendable {
    /// Workspace name from the server.
    public let workspace: String?

    /// Channel the event landed on.
    public let channel: String?

    /// Non-fatal warnings from the server. Empty when there are none.
    public let warnings: [String]
}
