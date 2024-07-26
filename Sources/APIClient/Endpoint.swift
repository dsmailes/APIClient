//
//  Endpoint.swift
//
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation

public protocol EndPointProtocol {
    var urlSuffix: String { get }
    var httpMethod: String { get }
}
