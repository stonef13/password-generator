//
//  PasswordGenerator.swift
//  password-generator
//
//  Created by Stone Fuglaar on 7/28/26.
//

import Foundation
import Security

struct PasswordGenerator {

    static let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static let lowercase = "abcdefghijklmnopqrstuvwxyz"
    static let numbers = "0123456789"
    static let symbols = "!@#$%^&*()-_=+[]{}|;:',.<>?/"

    static func generate(
        length: Int = 12,
        useUppercase: Bool = true,
        useLowercase: Bool = true,
        useNumbers: Bool = true,
        useSymbols: Bool = true
    ) -> String {
        var pool = ""
        if useUppercase { pool += uppercase }
        if useLowercase { pool += lowercase }
        if useNumbers { pool += numbers }
        if useSymbols { pool += symbols }

        precondition(!pool.isEmpty, "At least one character type must be enabled")

        var password = ""
        for _ in 0..<length {
            let randomIndex = secureRandomIndex(upTo: pool.count)
            let index = pool.index(pool.startIndex, offsetBy: randomIndex)
            password.append(pool[index])
        }
        return password
    }

    static func canGenerate(
        useUppercase: Bool,
        useLowercase: Bool,
        useNumbers: Bool,
        useSymbols: Bool
    ) -> Bool {
        return useUppercase || useLowercase || useNumbers || useSymbols
    }

    private static func secureRandomIndex(upTo bound: Int) -> Int {
        var randomByte: UInt8 = 0
        let status = SecRandomCopyBytes(kSecRandomDefault, 1, &randomByte)
        guard status == errSecSuccess else {
            fatalError("Failed to generate secure random byte: \(status)")
        }
        return Int(randomByte) % bound
    }
}
