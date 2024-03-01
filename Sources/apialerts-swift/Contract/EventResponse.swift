//
//  File.swift
//  
//
//  Created by Mononz on 1/3/2024.
//

import Foundation

struct EventResponse: Codable {
    let project: String?
    let remainingQuota: Int?
    let errors: [String]?
}
