//
//  APIError.swift
//
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation

enum APIError: Error {
    case requestFailed(description: String)
    case decodingFailure
    case invalidConfiguration
    
    var errorDescription: String {
        switch self {
        case .requestFailed(let description): return "Failed with response: \(description)"
        case .decodingFailure: return "Failed to decode data"
        case .invalidConfiguration: return "API not configured"
        }
    }
}
