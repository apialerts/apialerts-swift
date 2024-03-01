# API Alerts - Swift

In development. NOT ready for production use!

APIAlerts require the use of API Keys to integrate with your projects.

Copy your API Key from the projects page in the mobile app.

Get the App
- Android - [Play Store](https://play.google.com/store/apps/details?id=com.apialerts)
- iOS/Mac - [App Store](https://apps.apple.com/us/app/magpie-api-alerts/id6476410789)

Links
- [Integrations](https://apialerts.com/integrations)

## Installation

Available only as a SPM package from github

### Xcode Package Manager

import the library
```
https://github.com/apialerts/APIAlerts-Swift.git
```

### Swift Package.swift

Add the following to your `Package.swift` dependencies

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/apialerts/APIAlerts-Swift.git", exact: "0.0.2")
    ],
    targets: [
        .target(
            ...
            dependencies: [
                .product(name: "APIAlerts", package: "APIAlerts-Swift"),
            ]
        )
    ]
```

## Usage

Import the APIAlerts package

```swift
import APIAlerts
```

### Simple

Quick one-liner to send a notification to your connected devices.

```swift
APIAlerts.client.send(apiKey: "your-api-key", message: "New App User!")
```

### Advanced

Set a default API Key for all send() calls.
Provide an apiKey to send if you have multiple projects and want to send specific events to different projects.

```swift
// Set the default api key to use in all send() calls at any time in your app
APIAlerts.client.configure(
    apiKey: "your-api-key"
)

// Call send() without an apiKey parameter
APIAlerts.client.send(message: "New App User!")

// Or, provide an override for the default API Key
APIAlerts.client.send(apiKey: "your-other-api-key", message: "New App User!")
```

### Optional Properties
```swift
APIAlerts.client.send(
    message: "New App User!",
    tags: ["tag1", "tag2"],
    link: "https://apialerts.com/integrations"
)
```
