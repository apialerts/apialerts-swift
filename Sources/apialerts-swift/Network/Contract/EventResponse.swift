import Foundation

struct EventResponse: Decodable {
    let workspace: String?
    let channel: String?
    let warnings: [String]?
}
