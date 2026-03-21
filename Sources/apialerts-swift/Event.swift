import Foundation

public struct Event: Sendable {
    public var message: String
    public var channel: String?
    public var event: String?
    public var title: String?
    public var tags: [String]?
    public var link: String?
    public var data: (any Encodable & Sendable)?

    public init(
        message: String,
        channel: String? = nil,
        event: String? = nil,
        title: String? = nil,
        tags: [String]? = nil,
        link: String? = nil,
        data: (any Encodable & Sendable)? = nil
    ) {
        self.message = message
        self.channel = channel
        self.event = event
        self.title = title
        self.tags = tags
        self.link = link
        self.data = data
    }
}
