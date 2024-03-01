import Foundation

struct EventRequest: Codable {
    let message: String
    let tags: [String]?
    let link: String?
}
