//
//  AuthenticationClient.swift
//
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation

public protocol AuthenticationClientProtocol {
    
    func authenticateRequest(_ request: URLRequest) throws -> URLRequest
    func requestToken() async throws
    func fetchStoredToken() throws -> OAuthAccessToken
    
}
