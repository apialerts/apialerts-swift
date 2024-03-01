import Foundation

struct ErrorObject: Error {
    let statusCode: Int
    let message: String
}
