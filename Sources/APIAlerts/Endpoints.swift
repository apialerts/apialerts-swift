//
//  File.swift
//  
//
//  Created by Mononz on 1/3/2024.
//

import Foundation

struct EventEndpoints {
    static func send(_ apiKey: String, _ payload: EventRequest) async -> Result<EventResponse, ErrorObject> {
        let body: Data? = try? getEncoder().encode(payload)
        return await ApiClient.shared.request(
            apiKey: apiKey,
            method: .post,
            path: "/event",
            body: body
        )
    }
}
