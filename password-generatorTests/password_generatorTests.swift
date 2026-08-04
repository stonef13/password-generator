//
//  password_generatorTests.swift
//  password-generatorTests
//
//  Created by Stone Fuglaar  on 7/28/26.
//

import Testing
@testable import password_generator

struct password_generatorTests {

    // MARK: - Default Generation

    @Test func defaultPasswordIs12Characters() {
        let password = PasswordGenerator.generate()
        #expect(password.count == 12)
    }

    @Test func defaultPasswordContainsUppercase() {
        let password = PasswordGenerator.generate()
        let hasUppercase = password.contains { $0.isUppercase }
        #expect(hasUppercase)
    }

    @Test func defaultPasswordContainsLowercase() {
        let password = PasswordGenerator.generate()
        let hasLowercase = password.contains { $0.isLowercase }
        #expect(hasLowercase)
    }

    @Test func defaultPasswordContainsNumber() {
        let password = PasswordGenerator.generate()
        let hasNumber = password.contains { $0.isNumber }
        #expect(hasNumber)
    }

    @Test func defaultPasswordContainsSymbol() {
        let symbols = PasswordGenerator.symbols
        let password = PasswordGenerator.generate()
        let hasSymbol = password.contains { symbols.contains($0) }
        #expect(hasSymbol)
    }

    // MARK: - Custom Length

    @Test func customLength4() {
        let password = PasswordGenerator.generate(length: 4)
        #expect(password.count == 4)
    }

    @Test func customLength8() {
        let password = PasswordGenerator.generate(length: 8)
        #expect(password.count == 8)
    }

    @Test func customLength16() {
        let password = PasswordGenerator.generate(length: 16)
        #expect(password.count == 16)
    }

    @Test func customLength32() {
        let password = PasswordGenerator.generate(length: 32)
        #expect(password.count == 32)
    }

    // MARK: - Single Character Type

    @Test func uppercaseOnly() {
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: true,
            useLowercase: false,
            useNumbers: false,
            useSymbols: false
        )
        #expect(password.allSatisfy { $0.isUppercase })
    }

    @Test func lowercaseOnly() {
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: false,
            useLowercase: true,
            useNumbers: false,
            useSymbols: false
        )
        #expect(password.allSatisfy { $0.isLowercase })
    }

    @Test func numbersOnly() {
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: false,
            useLowercase: false,
            useNumbers: true,
            useSymbols: false
        )
        #expect(password.allSatisfy { $0.isNumber })
    }

    @Test func symbolsOnly() {
        let symbols = PasswordGenerator.symbols
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: false,
            useLowercase: false,
            useNumbers: false,
            useSymbols: true
        )
        #expect(password.allSatisfy { symbols.contains($0) })
    }

    // MARK: - Uniqueness

    @Test func generatesUniquePasswords() {
        var passwords = Set<String>()
        for _ in 0..<100 {
            passwords.insert(PasswordGenerator.generate())
        }
        #expect(passwords.count == 100)
    }

    // MARK: - Edge Cases

    @Test func lengthExactly1() {
        let password = PasswordGenerator.generate(length: 1)
        #expect(password.count == 1)
    }

    @Test func canGenerateReturnsFalseWhenAllDisabled() {
        let result = PasswordGenerator.canGenerate(
            useUppercase: false,
            useLowercase: false,
            useNumbers: false,
            useSymbols: false
        )
        #expect(result == false)
    }

    @Test func canGenerateReturnsTrueWhenAtLeastOneEnabled() {
        let result = PasswordGenerator.canGenerate(
            useUppercase: true,
            useLowercase: false,
            useNumbers: false,
            useSymbols: false
        )
        #expect(result == true)
    }

    // MARK: - Multiple Character Types

    @Test func uppercaseAndLowercaseOnly() {
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: true,
            useLowercase: true,
            useNumbers: false,
            useSymbols: false
        )
        #expect(password.allSatisfy { $0.isLetter })
    }

    @Test func uppercaseAndNumbersOnly() {
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: true,
            useLowercase: false,
            useNumbers: true,
            useSymbols: false
        )
        #expect(password.allSatisfy { $0.isUppercase || $0.isNumber })
    }

    @Test func lowercaseAndSymbolsOnly() {
        let symbols = PasswordGenerator.symbols
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: false,
            useLowercase: true,
            useNumbers: false,
            useSymbols: true
        )
        #expect(password.allSatisfy { $0.isLowercase || symbols.contains($0) })
    }

    @Test func threeTypesExcludingSymbols() {
        let symbols = PasswordGenerator.symbols
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: true,
            useLowercase: true,
            useNumbers: true,
            useSymbols: false
        )
        #expect(password.allSatisfy { !$0.isSymbol || !symbols.contains($0) })
    }

    @Test func threeTypesExcludingLowercase() {
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: true,
            useLowercase: false,
            useNumbers: true,
            useSymbols: true
        )
        #expect(password.allSatisfy { !$0.isLowercase })
    }
}
