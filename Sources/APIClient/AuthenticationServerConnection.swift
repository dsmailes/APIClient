//
//  AuthenticationServerConnection.swift
//
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation

protocol AuthenticationServerConnectionProtocol {
    var serverURL: URL { get }
    var clientID: String { get }
    var clientSecret: String { get }
    
    func getAuthenticationToken() async throws -> OAuthAccessToken
}
