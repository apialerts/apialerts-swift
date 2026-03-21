import Foundation

struct Network {
    var session: URLSession
    var integration: String
    var version: String
    var baseUrl: String

    init(
        session: URLSession = .shared,
        integration: String = integrationName,
        version: String = integrationVersion,
        baseUrl: String = "https://api.apialerts.com"
    ) {
        self.session = session
        self.integration = integration
        self.version = version
        self.baseUrl = baseUrl
    }

    func post(apiKey: String, event: Event) async -> SendResult {
        guard let url = URL(string: baseUrl + "/event") else {
            return SendResult(success: false, workspace: nil, channel: nil, warnings: [], error: "invalid response from server")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(integration, forHTTPHeaderField: "X-Integration")
        request.setValue(version, forHTTPHeaderField: "X-Version")

        do {
            request.httpBody = try JSONEncoder().encode(EventRequest(from: event))
        } catch {
            return SendResult(success: false, workspace: nil, channel: nil, warnings: [], error: "invalid response from server")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            return SendResult(success: false, workspace: nil, channel: nil, warnings: [], error: error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return SendResult(success: false, workspace: nil, channel: nil, warnings: [], error: "invalid response from server")
        }

        switch httpResponse.statusCode {
        case 200:
            do {
                let result = try JSONDecoder().decode(EventResponse.self, from: data)
                return SendResult(
                    success: true,
                    workspace: result.workspace,
                    channel: result.channel,
                    warnings: result.warnings,
                    error: nil
                )
            } catch {
                return SendResult(success: false, workspace: nil, channel: nil, warnings: [], error: "invalid response from server")
            }
        case 400:
            return SendResult(success: false, workspace: nil, channel: nil, warnings: [], error: "bad request")
        case 401:
            return SendResult(success: false, workspace: nil, channel: nil, warnings: [], error: "unauthorized — check your api key")
        case 403:
            return SendResult(success: false, workspace: nil, channel: nil, warnings: [], error: "forbidden")
        case 429:
            return SendResult(success: false, workspace: nil, channel: nil, warnings: [], error: "rate limit exceeded")
        default:
            return SendResult(success: false, workspace: nil, channel: nil, warnings: [], error: "unexpected status: \(httpResponse.statusCode)")
        }
    }
}
