import Foundation

struct EventRequest: Codable {
    let channel: String?
    let message: String
    let tags: [String]?
    let link: String?
}
