import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

struct Network {
    var session: URLSession
    var integration: String
    var version: String
    var baseUrl: String

    init(
        session: URLSession = .shared,
        integration: String = integrationName,
        version: String = integrationVersion,
        baseUrl: String = defaultBaseUrl
    ) {
        self.session = session
        self.integration = integration
        self.version = version
        self.baseUrl = baseUrl
    }

    func post(apiKey: String, event: Event) async -> Result<SendResult, ApiAlertsError> {
        guard let url = URL(string: baseUrl) else {
            return .failure(.invalidResponse)
        }

        var request = URLRequest(url: url, timeoutInterval: timeoutSeconds)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(integration, forHTTPHeaderField: "X-Integration")
        request.setValue(version, forHTTPHeaderField: "X-Version")

        do {
            request.httpBody = try JSONEncoder().encode(EventRequest(from: event))
        } catch {
            return .failure(.invalidResponse)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.invalidResponse)
        }

        switch httpResponse.statusCode {
        case 200:
            do {
                let body = try JSONDecoder().decode(EventResponse.self, from: data)
                return .success(
                    SendResult(
                        workspace: body.workspace,
                        channel: body.channel,
                        warnings: body.warnings ?? []
                    ))
            } catch {
                return .failure(.invalidResponse)
            }
        case 400: return .failure(.httpError(400, "bad request"))
        case 401: return .failure(.httpError(401, "unauthorized, check your api key"))
        case 403: return .failure(.httpError(403, "forbidden"))
        case 429: return .failure(.httpError(429, "rate limit exceeded"))
        default: return .failure(.httpError(httpResponse.statusCode, "unexpected status: \(httpResponse.statusCode)"))
        }
    }
}
