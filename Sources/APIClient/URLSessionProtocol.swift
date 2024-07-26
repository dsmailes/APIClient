//
//  File.swift
//  
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation

protocol URLSessionProtocol {
    func dataTaskWithURL(_ request: URLRequest) async throws -> DataTaskResult
}

extension URLSession: URLSessionProtocol {
    func dataTaskWithURL(_ request: URLRequest) async throws -> DataTaskResult {
        try await self.data(for: request)
    }
}
