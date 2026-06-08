import APIAlerts
import Foundation

let args = Array(CommandLine.arguments.dropFirst())

let isBuild = args.contains("--build")
let isRelease = args.contains("--release")
let isPublish = args.contains("--publish")
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

func handleResult(_ result: Result<SendResult, ApiAlertsError>) {
    switch result {
    case .success(let sent):
        print("✓ Sent to \(sent.workspace ?? "") (\(sent.channel ?? ""))")
    case .failure(let error):
        fputs("Error: \(error.localizedDescription)\n", stderr)
        exit(1)
    }
}

if isBuild {
    handleResult(
        await APIAlerts.sendAsync(
            Event(
                message: "Swift SDK - PR build success",
                channel: "developer",
                event: "ci.sdk.build.swift",
                title: "Build Passed",
                tags: ["CI/CD", "Swift", "Build"],
                link: link
            )))

} else if isRelease {
    handleResult(
        await APIAlerts.sendAsync(
            Event(
                message: "Swift SDK - Build for publish success",
                channel: "developer",
                event: "ci.sdk.release.swift",
                title: "Release Build Passed",
                tags: ["CI/CD", "Swift", "Build"],
                link: link
            )))

} else if isPublish {
    handleResult(
        await APIAlerts.sendAsync(
            Event(
                message: "Swift SDK - Swift Package Index publish success",
                channel: "releases",
                event: "ci.sdk.publish.swift",
                title: "Published",
                tags: ["CI/CD", "Swift", "Deploy"],
                link: link
            )))

} else if isIntegrationTests {
    let minimal = await APIAlerts.sendAsync(Event(message: "Swift SDK - minimal", channel: channel))
    switch minimal {
    case .success(let sent):
        print("✓ sent to \(sent.workspace ?? "") (\(sent.channel ?? ""))")
    case .failure(let error):
        fputs("Error (minimal): \(error.localizedDescription)\n", stderr)
        exit(1)
    }

    let full = await APIAlerts.sendAsync(
        Event(
            message: "Swift SDK - full",
            channel: channel,
            event: "sdk.test",
            title: "Integration Test",
            tags: ["CI/CD", "Swift"],
            link: link
        ))
    switch full {
    case .success(let sent):
        print("✓ sent to \(sent.workspace ?? "") (\(sent.channel ?? ""))")
        for w in sent.warnings { print("! Warning: \(w)") }
    case .failure(let error):
        fputs("Error (full): \(error.localizedDescription)\n", stderr)
        exit(1)
    }

} else {
    fputs("Error: pass --build, --release, --publish, or --integration-tests\n", stderr)
    exit(1)
}
