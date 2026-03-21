import Foundation

public struct SendResult: Sendable {
    public let success: Bool
    public let workspace: String?
    public let channel: String?
    public let warnings: [String]
    public let error: String?
}
