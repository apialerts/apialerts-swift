import SwiftUI

/// API Alerts Client
///
/// Shorthand for APIAlertsClient.client
///
public let APIAlerts = APIAlertsClient.client

///
/// API Alerts Client
///
public class APIAlertsClient {

    public static let client = APIAlertsClient()

    let alerts: Client = ClientImpl()

    private init() {}

    /// Configure the APIAlerts client
    ///
    /// Example:
    /// ```
    /// APIAlerts.configure(
    ///     apiKey: "abcd-efgh-ijkl-mnop-qrst",
    ///     debug: true
    /// )
    /// ```
    ///
    /// Parameters:
    /// apiKey: The APIAlerts project API key. Provide a default API Key to use for all send() requests
    /// debug: Boolean Set to true to enable debug logging
    /// Returns: Void
    public func configure(apiKey: String, debug: Bool = false) {
        print("alerts.configure")
        alerts.configure(apiKey: apiKey, debug: debug)
    }

    /// Send an alert
    ///
    /// Example:
    /// ```
    /// APIAlerts.send(
    ///     apiKey: "abcd-efgh-ijkl-mnop-qrst",
    ///     channel: "developer"
    ///     message: "Swift package test",
    ///     tags: ["swift", "apple"],
    ///     link: "https://developer.apple.com/documentation/swift"
    /// )
    /// ```
    ///
    /// Parameters:
    /// apiKey: The APIAlerts project API key. Overrides the default apiKey if set in configure()
    /// channel: Optional channel to send the alert to. Uses the default channel set if not provided
    /// message: The message to send
    /// tags: Optional array of tags to associate with the message. Max of 10 tags with each tag length no greater than 50 characters. Non compliant tags will be dropped.
    /// link: Optional link to associate with the message
    /// Returns: Void
    public func send(apiKey: String? = nil, channel: String? = nil, message: String, tags: [String]? = nil, link: String? = nil) {
        print("alerts.send")
        alerts.send(apiKey: apiKey, channel: channel, message: message, tags: tags, link: link)
    }

    /// Send an alert
    /// Async suspend function that will wait for a response
    ///
    /// Example:
    /// ```
    /// APIAlerts.send(
    ///     apiKey: "abcd-efgh-ijkl-mnop-qrst",
    ///     channel: "developer"
    ///     message: "Swift package test",
    ///     tags: ["swift", "apple"],
    ///     link: "https://developer.apple.com/documentation/swift"
    /// )
    /// ```
    ///
    /// Parameters:
    /// apiKey: The APIAlerts project API key. Overrides the default apiKey if set in configure()
    /// channel: Optional channel to send the alert to. Uses the default channel set if not provided
    /// message: The message to send
    /// tags: An array of tags to associate with the message. Max of 10 tags with each tag length no greater than 50 characters. Non compliant tags will be dropped.
    /// link: A link to associate with the message
    /// Returns: Void
    public func sendAsync(apiKey: String? = nil, channel: String? = nil, message: String, tags: [String]? = nil, link: String? = nil) async {
        print("alerts.sendAsync")
        await alerts.sendAsync(apiKey: apiKey, channel: channel, message: message, tags: tags, link: link)
    }
}
