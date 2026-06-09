///
/// Used in the GitHub Action workflow to send an event on build success and publish.
/// Accepts one of --build, --release, --publish arguments.
///

import APIAlerts
import Foundation

let apiKey = ProcessInfo.processInfo.environment["APIALERTS_API_KEY"] ?? {
    fatalError("'APIALERTS_API_KEY' environment variable not provided")
}()

APIAlerts.configure(apiKey, debug: true)

var channel = "developer"
var message = "apialerts-swift"
var tags: [String]? = nil
let link = "https://github.com/apialerts/apialerts-swift/actions"

if CommandLine.arguments.contains("--build") {
    message = "Swift - PR build success"
    tags = ["CI/CD", "Swift", "Build"]
} else if CommandLine.arguments.contains("--release") {
    message = "Swift - Build for publish success"
    tags = ["CI/CD", "Swift", "Build"]
} else if CommandLine.arguments.contains("--publish") {
    channel = "releases"
    message = "Swift - GitHub publish success"
    tags = ["CI/CD", "Swift", "Deploy"]
}

_ = try await APIAlerts.sendAsync(Event(
    message: message,
    channel: channel,
    tags: tags,
    link: link
))
