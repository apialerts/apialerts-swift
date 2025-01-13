import Foundation

struct EventResponse: Codable {
    let workspace: String?
    let channel: String?
    let remainingQuota: Int?
    let errors: [String]?
}
