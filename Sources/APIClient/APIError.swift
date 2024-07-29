//
//  APIError.swift
//
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation

public enum APIError: Error {
    case requestFailed(description: String)
    case decodingFailure
    case invalidConfiguration
    
    var localizedDescription: String {
        switch self {
        case .requestFailed(let description):
            return NSLocalizedString("Failed with response: \(description)", comment: "Request failed error")
        case .decodingFailure:
            return NSLocalizedString("Failed to decode data", comment: "Decoding failure error")
        case .invalidConfiguration:
            return NSLocalizedString("API not configured", comment: "Invalid configuration error")
        }
    }
}
