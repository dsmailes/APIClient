//
//  AuthenticationClient.swift
//
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation

public protocol AuthenticationClientProtocol {
    
    func authenticateRequest(_ request: URLRequest) async throws -> URLRequest
    func requestToken() async throws
    func fetchStoredToken() async throws -> OAuthAccessToken
    
}

public final class DefaultAuthenticationClient: AuthenticationClientProtocol {
    
    internal var keychainInteractor: KeychainInteractor
    private let authenticationServer: AuthenticationServerConnectionProtocol
    
    init(
        authenticationServer: AuthenticationServerConnectionProtocol,
        keychainInteractor: KeychainInteractor
    ) {
        self.authenticationServer = authenticationServer
        self.keychainInteractor = keychainInteractor
    }
    
    public func fetchStoredToken() async throws -> OAuthAccessToken {
        try keychainInteractor.read(withKey: "authToken")
    }
    
    public func requestToken() async throws {
        let token = try await authenticationServer.getAuthenticationToken()
        try keychainInteractor.add(token, withKey: "authToken")
    }
    
    public func authenticateRequest(_ request: URLRequest) async throws -> URLRequest {
        let token = try await fetchStoredToken()
        
        var authenticatedRequest = request
        authenticatedRequest.addValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization")
        
        return authenticatedRequest
    }
    
}