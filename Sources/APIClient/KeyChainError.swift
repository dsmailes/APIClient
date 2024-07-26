//
//  KeyChainError.swift
//
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation

public struct KeychainError: Error {
    var status: OSStatus
    var localizedDescription: String {
        SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
    }
}
