//
//  AuthenticationServerConnection.swift
//
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation

public protocol AuthenticationServerConnectionProtocol {
    var serverURL: URL { get }
    var clientID: String { get }
    var clientSecret: String { get }
    
    func getAuthenticationToken() async throws -> OAuthAccessToken
}

extension AuthenticationClientProtocol {
    public func getAuthenticationToken() async throws -> OAuthAccessToken {
        return OAuthAccessToken(token: "")
    }
}
