# API Alerts • Swift Client

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fapialerts%2Fapialerts-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/apialerts/apialerts-swift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fapialerts%2Fapialerts-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/apialerts/apialerts-swift)

[GitHub](https://github.com/apialerts/apialerts-swift) • [Swift Package Index](https://swiftpackageindex.com/apialerts/apialerts-swift)

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
APIAlerts.configure(
    apiKey: "your-api-key"
)
```

Configuring the client is optional, but it allows you to set a default API Key for all send() calls. You must set an API key in the send() call if you do not configure the client.

### Send Events

Quick one-liner to send a notification to your connected devices.

```swift
APIAlerts.send(
    apiKey: "your-api-key",   // Optional, uses the key from ApiAlerts.client.configure() if not provided
    channel: "your-channel",  // Optional, uses the default channel if not provided
    message: "New App User!"  // Required
)
```

Additional event properties can be set using the optional parameters.

```swift
APIAlerts.send(
    apiKey: "your-api-key",        // Optional, uses the key from ApiAlerts.client.configure() if not provided
    channel: "your-channel",       // Optional, uses the default channel if not provided
    message: "New App User!",      // Required
    tags: ["tag1", "tag2"],        // Optional tags
    link: "https://apialerts.com"  // Optional link
)
```

The API Key provided in the send() function can be different from the default API Key set in the configure() function. This allows you to send events to different workspaces without changing the default API Key or managing multiple instances of the client.

The APIAlerts.sendAsync methods are also available if you need to wait for a successful execution. However, the send() functions are generally always preferred.
