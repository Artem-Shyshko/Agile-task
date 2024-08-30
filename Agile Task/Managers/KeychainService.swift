//
//  KeychainService.swift
//  Agile Password
//
//  Created by USER on 19.04.2024.
//

import Foundation

struct PasswordData: Codable, Hashable {
    let account: String
    let password: String
    let key: String
    let url: String
}

class KeychainService {
    class func saveOrUpdateStringArray(strings: [String], forKey key: String) {
        guard let data = try? JSONEncoder().encode(strings) else {
            return
        }
        
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String : Any]
        
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    class func getStringArray(forKey key: String) -> [String]? {
        guard let data = loadRawData(key: key) else {
            return nil
        }
        
        do {
            let stringArray = try JSONDecoder().decode([String].self, from: data)
            return stringArray
        } catch {
            return nil
        }
    }
    
    class func save(passwordData: PasswordData) {
        guard let data = try? JSONEncoder().encode(passwordData) else {
            return
        }
        
        if loadPasswordData(key: passwordData.key) != nil {
            let deleteQuery = [
                kSecClass as String: kSecClassGenericPassword as String,
                kSecAttrAccount as String: passwordData.key
            ] as [String : Any]
            
            let _ = SecItemDelete(deleteQuery as CFDictionary)
        }
        
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: passwordData.key,
            kSecValueData as String: data
        ] as [String : Any]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    class func loadPasswordData(key: String) -> PasswordData? {
        if let data = loadRawData(key: key) {
            do {
                let passwordData = try JSONDecoder().decode(PasswordData.self, from: data)
                return passwordData
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    class func save(key: String, data: Data) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    private class func loadRawData(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne ] as [String : Any]
        
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
}
