//
//  Endpoint.swift
//
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation

protocol EndPointProtocol {
    var urlSuffix: String { get }
    var httpMethod: String { get }
}
