import APIAlerts
import Foundation

let args = Array(CommandLine.arguments.dropFirst())

let isBuild            = args.contains("--build")
let isRelease          = args.contains("--release")
let isPublish          = args.contains("--publish")
let isIntegrationTests = args.contains("--integration-tests")

let channelIdx = args.firstIndex(of: "--channel")
let channel = channelIdx.flatMap { idx in idx + 1 < args.count ? args[idx + 1] : nil } ?? "testing"

let apiKey = ProcessInfo.processInfo.environment["APIALERTS_API_KEY"] ?? ""
if apiKey.isEmpty {
    fputs("Error: APIALERTS_API_KEY environment variable is not set\n", stderr)
    exit(1)
}

APIAlerts.configure(apiKey)

let link = "https://github.com/apialerts/apialerts-swift/actions"

if isBuild {
    let result = await APIAlerts.sendAsync(Event(
        message: "Swift SDK - PR build success",
        channel: "developer",
        event: "ci.build",
        title: "Build Passed",
        tags: ["CI/CD", "Swift", "Build"],
        link: link
    ))
    if result.success {
        print("✓ Sent to \(result.workspace ?? "") (\(result.channel ?? ""))")
    } else {
        fputs("Error: \(result.error ?? "unknown")\n", stderr)
        exit(1)
    }

} else if isRelease {
    let result = await APIAlerts.sendAsync(Event(
        message: "Swift SDK - Build for publish success",
        channel: "developer",
        event: "ci.release",
        title: "Release Build Passed",
        tags: ["CI/CD", "Swift", "Build"],
        link: link
    ))
    if result.success {
        print("✓ Sent to \(result.workspace ?? "") (\(result.channel ?? ""))")
    } else {
        fputs("Error: \(result.error ?? "unknown")\n", stderr)
        exit(1)
    }

} else if isPublish {
    let result = await APIAlerts.sendAsync(Event(
        message: "Swift SDK - Swift Package Index publish success",
        channel: "releases",
        event: "ci.publish",
        title: "Published",
        tags: ["CI/CD", "Swift", "Deploy"],
        link: link
    ))
    if result.success {
        print("✓ Sent to \(result.workspace ?? "") (\(result.channel ?? ""))")
    } else {
        fputs("Error: \(result.error ?? "unknown")\n", stderr)
        exit(1)
    }

} else if isIntegrationTests {
    let minimal = await APIAlerts.sendAsync(Event(message: "Swift SDK - minimal", channel: channel))
    if minimal.success {
        print("✓ sent to \(minimal.workspace ?? "") (\(minimal.channel ?? ""))")
    } else {
        fputs("Error (minimal): \(minimal.error ?? "unknown")\n", stderr)
        exit(1)
    }

    let full = await APIAlerts.sendAsync(Event(
        message: "Swift SDK - full",
        channel: channel,
        event: "sdk.test",
        title: "Integration Test",
        tags: ["CI/CD", "Swift"],
        link: link
    ))
    if full.success {
        print("✓ sent to \(full.workspace ?? "") (\(full.channel ?? ""))")
    } else {
        fputs("Error (full): \(full.error ?? "unknown")\n", stderr)
        exit(1)
    }
} else {
    fputs("Error: pass --build, --release, --publish, or --integration-tests\n", stderr)
    exit(1)
}
