import Combine
import Foundation
import SwiftUI

struct Network {

    static func request<T: Codable>(apiKey: String, method: HttpMethod, path: String, body: Data? = nil) async -> (Result<T, ErrorObject>) {
        guard let url = URL(string: API_URL + path) else {
            let output = ErrorObject(
                statusCode: 0,
                message: "Invalid request"
            )
            return .failure(output)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        var headers = [String: String]()
        headers["Authorization"] = "Bearer \(apiKey)"
        headers["Content-Type"] = "application/json"
        headers["X-Integration"] = INTEGRATION_NAME
        headers["X-Version"] = INTEGRATION_VERSION
        
        request.allHTTPHeaderFields = headers

        if let body = body {
            request.httpBody = body
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            var statusCode = 0
            if let httpResponse = response as? HTTPURLResponse {
                statusCode = httpResponse.statusCode
                if statusCode == 200 {
                    let jsonData = try getDecoder().decode(T.self, from: data)
                    return .success(jsonData)
                }
            }
            
            let error = try getDecoder().decode(ErrorResponse.self, from: data)
            let output = ErrorObject(
                statusCode: statusCode,
                message: error.message ?? "Unknown Error"
            )
            return .failure(output)
        } catch {
            let output = ErrorObject(
                statusCode: 0,
                message: "Something went wrong"
            )
            return .failure(output)
        }
    }
}
