# API Alerts • Swift Package

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fapialerts%2Fapialerts-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/apialerts/apialerts-swift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fapialerts%2Fapialerts-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/apialerts/apialerts-swift)

[Swift Package Index](https://swiftpackageindex.com/apialerts/apialerts-swift) • [GitHub](https://github.com/apialerts/apialerts-swift) • [API Alerts](https://apialerts.com)

Effortless project notifications. Send once, deliver everywhere.

## Installation

Add the package in Xcode via **File → Add Package Dependencies**:

```
https://github.com/apialerts/apialerts-swift
```

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/apialerts/apialerts-swift", exact: "1.2.0")
]
```

> We recommend pinning to an exact version.

## Quick Start

```swift
import APIAlerts

APIAlerts.configure("your-api-key")
await APIAlerts.send(Event(message: "Deploy complete"))
```

## Usage

### Global singleton (recommended)

Call `configure` once at startup, then use `send` / `sendAsync` anywhere.

```swift
import APIAlerts

APIAlerts.configure("your-api-key")

// Fire-and-forget — never throws, logs errors to stderr
await APIAlerts.send(Event(message: "Deploy complete"))

// Or get the result back
let result = await APIAlerts.sendAsync(Event(message: "Deploy complete"))
switch result {
case .success(let sent):
    print("Sent to \(sent.workspace) (\(sent.channel))")
    for warning in sent.warnings { print("Warning: \(warning)") }
case .failure(let error):
    print("Error: \(error.localizedDescription)")
}
```

## Event Fields

| Field     | Type                          | Required | Description                      |
|-----------|-------------------------------|----------|----------------------------------|
| `message` | `String`                      | Yes      | Main notification message        |
| `channel` | `String?`                     | No       | Target channel name              |
| `event`   | `String?`                     | No       | Event key for routing            |
| `title`   | `String?`                     | No       | Short title                      |
| `tags`    | `[String]?`                   | No       | Categorisation tags              |
| `link`    | `String?`                     | No       | URL attached to the notification |
| `data`    | `(any Encodable & Sendable)?` | No       | Arbitrary key-value metadata     |

### Instance-based client

Use `ApiAlertsClient` directly when you need multiple clients or full lifecycle control.

```swift
let client = ApiAlertsClient("your-api-key", debug: true)
let result = await client.sendAsync(Event(message: "Deploy complete"))
switch result {
case .success(let sent):
    print("Sent to \(sent.workspace) (\(sent.channel))")
case .failure(let error):
    print("Error: \(error.localizedDescription)")
}
```

## Links

- [Documentation](https://apialerts.com/docs)
- [Sign up](https://apialerts.com)
- [GitHub Issues](https://github.com/apialerts/apialerts-swift/issues)
