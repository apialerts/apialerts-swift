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

### Global singleton

Call `configure` once at startup, then use `send` / `sendAsync` anywhere.

```swift
import APIAlerts

APIAlerts.configure("your-api-key")

// Fire-and-forget. Never throws, drops errors silently unless debug is on.
await APIAlerts.send(Event(message: "Deploy complete"))

// Or get the result back. Never throws; switch on the Result.
let result = await APIAlerts.sendAsync(Event(message: "Deploy complete"))
switch result {
case .success(let sent):
    print("Sent to \(sent.workspace ?? "") (\(sent.channel ?? ""))")
case .failure(let error):
    print("Error: \(error.localizedDescription)")
}
```

### Enable debug logging

```swift
APIAlerts.configure("your-api-key", debug: true)
```

Critical errors (missing API key, not yet configured) always log. Success and warning messages only log when `debug` is enabled.

### Event fields

Only `message` is required. All other fields are optional and omitted from the request body when `nil`.

```swift
let event = Event(
    message: "Deploy complete",
    channel: "releases",
    event: "ci.deploy",
    title: "Deployed",
    tags: ["CI/CD", "Swift"],
    link: "https://github.com/apialerts/apialerts-swift/actions",
    data: ["commit": "a1b2c3d", "branch": "main"]
)

await APIAlerts.send(event)
```

`data` takes anything `Encodable` (a dictionary as above, or your own `Codable` struct) and is available to non-push destinations for templating.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `message` | `String` | Yes | Human-readable notification text. This is what appears on the push notification lock screen. |
| `channel` | `String?` | No | Workspace channel the push notification fires on. Defaults to the workspace default channel when omitted. |
| `event` | `String?` | No | Identifies what kind of thing happened. Optional but recommended. Use dotted notation (e.g. `ci.deploy.success`, `payment.failed`, `user.signup`) so routing rules can match glob patterns like `ci.*` or `*.failed`. |
| `title` | `String?` | No | Short headline some destinations render separately from the message body. |
| `tags` | `[String]?` | No | Categorisation tags for filtering and search. |
| `link` | `String?` | No | URL associated with the event. Available as a deeplink for push notifications and as a call-to-action for routed destinations. |
| `data` | `(any Encodable & Sendable)?` | No | Arbitrary key-value metadata. Available to non-push destinations for templating (Slack message bodies, email templates, webhook payloads). |

### Send to multiple workspaces

Pass an `apiKey` as the optional last argument to override the configured key for a single call.

```swift
await APIAlerts.send(Event(message: "Deploy complete"), apiKey: "other-workspace-api-key")

let result = await APIAlerts.sendAsync(
    Event(message: "Deploy complete"),
    apiKey: "other-workspace-api-key"
)
```

### Dependency injection

The singleton is fine for most apps. When you want injection, mocking, or multiple keys in one process, construct an `ApiAlertsClient` directly. It conforms to `ApiAlertsClientProtocol`, so hold the protocol type in your code and swap a stub in tests. The singleton is a thin facade over a default `ApiAlertsClient`, so both share the same behaviour.

```swift
import APIAlerts

struct DeployNotifier {
    let alerts: any ApiAlertsClientProtocol

    func notify() async {
        await alerts.send(Event(message: "Deploy complete"))
    }
}

// Production
let notifier = DeployNotifier(alerts: ApiAlertsClient("your-api-key"))
```

In tests, inject any type conforming to `ApiAlertsClientProtocol`. To test against the real client, inject a `URLSession` (e.g. one backed by a mock `URLProtocol`):

```swift
let client = ApiAlertsClient("your-api-key", debug: true, session: mockSession)
```

## API

| Method | Description |
|---|---|
| `APIAlerts.configure(_:debug:session:)` | Initialise the singleton. First call wins; subsequent calls are no-ops. |
| `APIAlerts.send(_:apiKey:)` | Fire-and-forget. Never throws, drops errors silently unless `debug` is on. |
| `APIAlerts.sendAsync(_:apiKey:)` | Awaitable, returns `Result<SendResult, ApiAlertsError>`. Never throws. |
| `ApiAlertsClient(_:debug:session:)` | Constructable instance client for dependency injection. Conforms to `ApiAlertsClientProtocol`; exposes the same `send` / `sendAsync` / `setOverrides`. |

### SendResult fields

| Field | Type | Description |
|---|---|---|
| `workspace` | `String?` | Workspace name (present on success) |
| `channel` | `String?` | Channel name (present on success) |
| `warnings` | `[String]` | Non-fatal warnings from the server |

Errors are surfaced via the `Result`'s `.failure(ApiAlertsError)` case, not as fields on `SendResult`.

## Links

- [Documentation](https://apialerts.com/docs/sdks/swift)
- [Sign up](https://apialerts.com)
- [GitHub Issues](https://github.com/apialerts/apialerts-swift/issues)
