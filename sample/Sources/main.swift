import APIAlerts
import Foundation

let args = CommandLine.arguments
let mode = args.dropFirst().first ?? "--build"

let apiKey = ProcessInfo.processInfo.environment["APIALERTS_API_KEY"] ?? {
    fatalError("'APIALERTS_API_KEY' environment variable not provided")
}()

APIAlerts.configure(apiKey)

// Minimal — message only
let minimal = await APIAlerts.sendAsync(Event(message: "Swift SDK - minimal"))
if minimal.success {
    print("✓ sent to \(minimal.workspace ?? "") (\(minimal.channel ?? ""))")
} else {
    print("x error: \(minimal.error ?? "unknown")")
}

// Full — all fields
let full = await APIAlerts.sendAsync(Event(
    message: "Swift SDK - full",
    channel: "developer",
    event: "sdk.test",
    title: "Integration Test",
    tags: ["CI/CD", "Swift"],
    link: "https://github.com/apialerts/apialerts-swift/actions"
))
if full.success {
    print("✓ sent to \(full.workspace ?? "") (\(full.channel ?? ""))")
} else {
    print("x error: \(full.error ?? "unknown")")
}
