import Foundation

/// The result of a successful event delivery.
public struct SendResult: Sendable {
    public let workspace: String
    public let channel: String
    public let warnings: [String]
}
