//
//  APIError.swift
//
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation

public enum APIError: LocalizedError {
    case requestFailed(description: String)
    case decodingFailure(description: String)
    case invalidConfiguration
    
    public var errorDescription: String? {
        switch self {
        case .requestFailed(let description):
            return NSLocalizedString("Failed with response: \(description)", comment: "Request failed error")
        case .decodingFailure(let description):
            return NSLocalizedString("Failed to decode data: \(description)", comment: "Decoding failure error")
        case .invalidConfiguration:
            return NSLocalizedString("API not configured", comment: "Invalid configuration error")
        }
    }
}
