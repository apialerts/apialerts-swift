///
/// Used in the GitHub Action workflow to send an event on build success and publish
/// Accepts one of --build, --release, --publish arguments
///

import APIAlerts
import Foundation

let apiKey = ProcessInfo.processInfo.environment["APIALERTS_API_KEY"] ?? {
    fatalError("'APIALERTS_API_KEY' environment variable not provided")
}()

// Configure the client
APIAlerts.configure(
    apiKey: apiKey,
    debug: true
)

// Event properties
var eventChannel = "developer"
var eventMessage = "apialerts-swift"
var eventTags: [String]? = nil
let eventLink = "https://github.com/apialerts/apialerts-swift/actions"

// Build properties
if CommandLine.arguments.contains("--build") {
    eventMessage = "Swift - PR build success"
    eventTags = ["CI/CD", "Swift", "Build"]
} else if CommandLine.arguments.contains("--release") {
    eventMessage = "Swift - Build for publish success"
    eventTags = ["CI/CD", "Swift", "Build"]
} else if CommandLine.arguments.contains("--publish") {
    eventChannel = "releases"
    eventMessage = "Swift - GitHub publish success"
    eventTags = ["CI/CD", "Swift", "Deploy"]
}

// Send the event
let task = Task {
    await APIAlerts.sendAsync(
        channel: eventChannel,
        message: eventMessage,
        tags: eventTags,
        link: eventLink
    )
}

// Await the task to ensure execution in the script
_ = await task.value
