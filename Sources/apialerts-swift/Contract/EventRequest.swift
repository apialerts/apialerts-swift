//
//  File.swift
//  
//
//  Created by Mononz on 1/3/2024.
//

import Foundation

struct EventRequest: Codable {
    let message: String
    let tags: [String]?
    let link: String?
}
