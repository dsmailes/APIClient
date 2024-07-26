//
//  KeyChainInteractor.swift
//
//
//  Created by David Smailes on 26/07/2024.
//

import Foundation
import Security

protocol KeychainInteractor {
    func add<T: Codable> (_ value: T, withKey key: String) throws
    func update<T: Codable> (_ value: T, withKey key: String) -> Bool
    func remove (withKey key: String) -> Bool
    func read <T: Codable> (withKey key: String) throws -> T
}

public struct DefaultKeychainInteractor: KeychainInteractor {
    public init() {}
    
    public func add<T: Codable> (_ value: T, withKey key: String) throws {

        let encoded = try JSONEncoder().encode(value)

        let query: [String: Any?] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: encoded
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess 
        else { throw KeychainError(status: status) }
    }

    @discardableResult
    public func update<T: Codable> (
        _ value: T,
        withKey key: String
    ) -> Bool {
        
        remove(withKey: key)

        do {
            try add(value, withKey: key)
        } catch {
            return false
        }
        return true
    }

    @discardableResult
    public func remove (withKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }

    public func read <T: Codable> (withKey key: String) throws -> T {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess
        else { throw KeychainError(status: status) }

        guard let existingItem = item as? [String: Any],
              let data = existingItem[kSecValueData as String] as? Data
        else { throw KeychainError(status: errSecInternalError) }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
