import SwiftUI

/**
 Basic Swift Wrapper to the APIAlerts platform. Allows sending to 
 */
public class APIAlerts {
    
    public static let client = APIAlerts()
    
    private init() {}
    
    private var commonApiKey: String? = nil
    private var showLogs: Bool = false
    
    /// Configure the APIAlerts client
    /// - Parameters:
    /// - apiKey: The APIAlerts project API key. Provide a default API Key to use for all send() requests
    /// - logging: Enable console logging for the APIAlerts client
    /// - Returns: Void
    public func configure(apiKey: String? = nil, logging: Bool = false) {
        commonApiKey = apiKey
        showLogs = logging
    }
    
    /// Send a message to the APIAlerts service
    ///
    /// Example:
    /// ```
    /// APIAlerts.client.send(
    ///     apiKey: "abcd-efgh-ijkl-mnop-qrst",
    ///     message: "Swift package test",
    ///     tags: ["swift", "apple"],
    ///     link: "https://developer.apple.com/documentation/swift"
    /// )
    /// ```
    ///
    /// - Parameters:
    ///  - apiKey: The APIAlerts project API key. Overrides the default apiKey if set in configure()
    ///  - message: The message to send
    ///  - tags: An array of tags to associate with the message. Max of 10 tags with each tag length no greater than 50 characters. Non compliant tags will be dropped.
    ///  - link: A link to associate with the message
    ///  - Returns: Void
    public func send(apiKey: String? = nil, message: String, tags: [String]? = nil, link: String? = nil) {
        guard let key = apiKey ?? commonApiKey else {
            print("APIAlerts -> Project API Key not provided. Use configure(apiKey: String) to set a default key, or pass the key as a parameter to the send function.")
            return
        }
        Task {
            let payload = EventRequest(
                message: message,
                tags: tags,
                link: link
            )
            let response = await EventEndpoints.send(key, payload)
            switch response {
            case .success(let data):
                if showLogs {
                    print("APIAlerts -> Successfully sent event to \(data.project ?? "??"). Remaining Quota = \(data.remainingQuota ?? 0)")
                    data.errors?.forEach { text in
                        print("APIAlerts Warning -> \(text)")
                    }
                }
            case .failure(let error):
                if showLogs {
                    print("APIAlerts -> Error: \(error.message)")
                }
            }
        }
    }
}
