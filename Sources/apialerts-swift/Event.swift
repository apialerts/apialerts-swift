import Foundation

/// A single notification dispatched to API Alerts.
///
/// Only ``message`` is required. All other fields are optional and omitted
/// from the request body when `nil` - they are never serialised as `null`.
public struct Event: Sendable {
    /// Human-readable notification text. Required. This is what appears on
    /// the push notification lock screen.
    public var message: String

    /// Workspace channel the push notification fires on. Defaults to the
    /// workspace default channel when omitted.
    public var channel: String?

    /// Identifies what kind of thing happened. Optional but recommended.
    /// Use dotted notation (e.g. `ci.deploy.success`, `payment.failed`,
    /// `user.signup`) so routing rules can match glob patterns like `ci.*`
    /// or `*.failed`.
    public var event: String?

    /// Short headline some destinations render separately from the message body.
    public var title: String?

    /// Categorisation tags for filtering and search.
    public var tags: [String]?

    /// URL associated with the event. Available as a deeplink for push
    /// notifications and as a call-to-action for routed destinations.
    public var link: String?

    /// Arbitrary key-value metadata. Available to non-push destinations for
    /// templating (Slack message bodies, email templates, webhook payloads).
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
