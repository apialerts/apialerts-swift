# API Alerts - Swift

Swift client for the [apialerts.com](https://apialerts.com/) platform

[Docs](https://apialerts.com/docs/swift) • [GitHub](https://github.com/apialerts/apialerts-swift)

## Installation

Add the following dependency to your Package.swift file

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/apialerts/apialerts-swift.git", exact: "<latest-version>")
    ],
    targets: [
        .target(
            ...
            dependencies: [
                .product(name: "APIAlerts", package: "apialerts-swift"),
            ]
        )
    ]
```

or install it via your xcode project
```bash
https://github.com/apialerts/apialerts-swift.git
```

Currently, apialerts-swift is only available as an SPM package.


### Initialize the client

```swift
import APIAlerts
...

// Set the default api key to use in all send() calls at any time in your app
APIAlerts.client.configure(
    apiKey: "your-api-key"
)
```

Configuring the client is optional, but it allows you to set a default API Key for all send() calls. You must set an API key in the send() call if you do not configure the client.

### Send Event

Quick one-liner to send a notification to your connected devices.

```swift
APIAlerts.client.send(
    apiKey: "your-api-key",  // Optional, uses the key from ApiAlerts.client.configure() if not provided
    message: "New App User!"
)
```

Additional event properties can be set using the optional parameters.

```swift
APIAlerts.client.send(
    apiKey: "your-api-key",  // Optional, uses the key from ApiAlerts.client.configure() if not provided
    message: "New App User!",
    tags: ["tag1", "tag2"],
    link: "https://apialerts.com/integrations"
)
```

The API Key provided in the send() function can be different from the default API Key set in the configure() function. This allows you to send events to different workspaces without changing the default API Key or managing multiple instances of the client.

### Feedback & Support

If you have any questions or feedback, please create an issue on our GitHub repository. We are always looking to improve our service and would love to hear from you. Thanks for using API Alerts!
