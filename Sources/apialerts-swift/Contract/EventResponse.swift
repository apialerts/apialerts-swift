import Foundation

struct EventResponse: Codable {
    let project: String?
    let remainingQuota: Int?
    let errors: [String]?
}
