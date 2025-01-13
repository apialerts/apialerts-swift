import Foundation

struct EventEndpoints {
    static func send(_ apiKey: String, _ payload: EventRequest) async -> Result<EventResponse, ErrorObject> {
        let body: Data? = try? getEncoder().encode(payload)
        return await Network.request(
            apiKey: apiKey,
            method: .post,
            path: "/event",
            body: body
        )
    }
}
