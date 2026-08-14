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
    static let ambiguous = "0O1lIo|'[]{};:,.<>?/"

    static func generate(
        length: Int = 12,
        useUppercase: Bool = true,
        useLowercase: Bool = true,
        useNumbers: Bool = true,
        useSymbols: Bool = true,
        excludeAmbiguous: Bool = false
    ) -> String {
        let uppercase = excludeAmbiguous ? ambiguousFree(Self.uppercase) : Self.uppercase
        let lowercase = excludeAmbiguous ? ambiguousFree(Self.lowercase) : Self.lowercase
        let numbers = excludeAmbiguous ? ambiguousFree(Self.numbers) : Self.numbers
        let symbols = excludeAmbiguous ? ambiguousFree(Self.symbols) : Self.symbols

        var pool = ""
        if useUppercase { pool += uppercase }
        if useLowercase { pool += lowercase }
        if useNumbers { pool += numbers }
        if useSymbols { pool += symbols }

        precondition(!pool.isEmpty, "At least one character type must be enabled")

        var enabledSets: [String] = []
        if useUppercase, !uppercase.isEmpty { enabledSets.append(uppercase) }
        if useLowercase, !lowercase.isEmpty { enabledSets.append(lowercase) }
        if useNumbers, !numbers.isEmpty { enabledSets.append(numbers) }
        if useSymbols, !symbols.isEmpty { enabledSets.append(symbols) }

        var characters: [Character] = []

        if length >= enabledSets.count {
            for set in enabledSets {
                characters.append(character(from: set))
            }
        }
        for _ in characters.count..<length {
            characters.append(character(from: pool))
        }

        secureShuffle(&characters)
        return String(characters)
    }

    static func canGenerate(
        useUppercase: Bool,
        useLowercase: Bool,
        useNumbers: Bool,
        useSymbols: Bool
    ) -> Bool {
        return useUppercase || useLowercase || useNumbers || useSymbols
    }

    static func ambiguousFree(_ characters: String) -> String {
        characters.filter { !ambiguous.contains($0) }
    }

    private static func character(from set: String) -> Character {
        let index = set.index(set.startIndex, offsetBy: secureRandomIndex(upTo: set.count))
        return set[index]
    }

    private static func secureRandomIndex(upTo bound: Int) -> Int {
        precondition(bound > 0)
        if bound == 1 { return 0 }
        while true {
            var randomByte: UInt8 = 0
            let status = SecRandomCopyBytes(kSecRandomDefault, 1, &randomByte)
            guard status == errSecSuccess else {
                fatalError("Failed to generate secure random byte: \(status)")
            }
            let value = Int(randomByte)
            if value < (256 / bound) * bound {
                return value % bound
            }
        }
    }

    private static func secureShuffle(_ array: inout [Character]) {
        for i in stride(from: array.count - 1, through: 1, by: -1) {
            let j = secureRandomIndex(upTo: i + 1)
            array.swapAt(i, j)
        }
    }
}
