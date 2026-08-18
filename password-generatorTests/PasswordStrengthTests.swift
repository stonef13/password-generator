//
//  PasswordStrengthTests.swift
//  password-generatorTests
//
//  Created by Stone Fuglaar on 8/18/26.
//

import Testing
@testable import password_generator

struct PasswordStrengthTests {

    // MARK: - Empty String

    @Test func emptyStringIsWeak() {
        #expect(PasswordStrengthCalculator.strength(of: "") == .weak)
    }

    @Test func emptyStringEntropyIsZero() {
        #expect(PasswordStrengthCalculator.entropy(of: "") == 0)
    }

    // MARK: - Class Pool Detection

    @Test func uppercaseOnlyPoolIs26() {
        #expect(PasswordStrengthCalculator.characterClassPoolSize(of: "ABC") == 26)
    }

    @Test func lowercaseOnlyPoolIs26() {
        #expect(PasswordStrengthCalculator.characterClassPoolSize(of: "abc") == 26)
    }

    @Test func digitsOnlyPoolIs10() {
        #expect(PasswordStrengthCalculator.characterClassPoolSize(of: "123") == 10)
    }

    @Test func symbolsOnlyPoolIsSymbolCount() {
        #expect(PasswordStrengthCalculator.characterClassPoolSize(of: "!@#") == PasswordGenerator.symbols.count)
    }

    @Test func upperAndLowerPoolIs52() {
        #expect(PasswordStrengthCalculator.characterClassPoolSize(of: "Abc") == 52)
    }

    @Test func upperLowerDigitsPoolIs62() {
        #expect(PasswordStrengthCalculator.characterClassPoolSize(of: "Abc1") == 62)
    }

    @Test func allFourTypesPoolIs87() {
        let expected = 26 + 26 + 10 + PasswordGenerator.symbols.count
        #expect(PasswordStrengthCalculator.characterClassPoolSize(of: "Abc1!") == expected)
    }

    // MARK: - Variety Axis (same length, more classes → stronger)

    @Test func varietyIncreasesStrength() {
        let single    = "abcdefghijkl"   // 12 chars, pool 26 → ~56.4 → medium
        let allTypes  = "aB3$efGH5@kL"   // 12 chars, pool 87 → ~77.3 → strong
        #expect(PasswordStrengthCalculator.strength(of: single) == .medium)
        #expect(PasswordStrengthCalculator.strength(of: allTypes) == .strong)
    }

    // MARK: - Length Axis (same classes, longer → stronger)

    @Test func lengthIncreasesStrength() {
        let short = "abcdefghij"   // 10 chars, pool 26 → medium
        let long  = "abcdefghijklmnop" // 16 chars, pool 26 → strong
        #expect(PasswordStrengthCalculator.strength(of: short) == .medium)
        #expect(PasswordStrengthCalculator.strength(of: long) == .strong)
    }

    // MARK: - Band Boundaries (entropy = 45 and 70)

    @Test func justBelowWeakMediumBoundaryIsWeak() {
        let password = String(repeating: "a", count: 9) // 9 × log2(26) ≈ 42.3
        #expect(PasswordStrengthCalculator.strength(of: password) == .weak)
    }

    @Test func justAboveWeakMediumBoundaryIsMedium() {
        let password = String(repeating: "a", count: 10) // 10 × log2(26) ≈ 47.0
        #expect(PasswordStrengthCalculator.strength(of: password) == .medium)
    }

    @Test func justBelowMediumStrongBoundaryIsMedium() {
        let password = String(repeating: "a", count: 14) // 14 × log2(26) ≈ 65.8
        #expect(PasswordStrengthCalculator.strength(of: password) == .medium)
    }

    @Test func justAboveMediumStrongBoundaryIsStrong() {
        let password = String(repeating: "a", count: 15) // 15 × log2(26) ≈ 70.5
        #expect(PasswordStrengthCalculator.strength(of: password) == .strong)
    }

    // MARK: - Common Configurations

    @Test func fourCharAllTypesIsWeak() {
        let password = "aB1!"  // 4 × log2(87) ≈ 25.8
        #expect(PasswordStrengthCalculator.strength(of: password) == .weak)
    }

    @Test func twelveCharLowercaseOnlyIsMedium() {
        let password = "abcdefghijkl"  // 12 × log2(26) ≈ 56.4
        #expect(PasswordStrengthCalculator.strength(of: password) == .medium)
    }

    @Test func twelveCharAllTypesIsStrong() {
        let password = "aB3$efGH5@kL"  // 12 × log2(87) ≈ 77.3
        #expect(PasswordStrengthCalculator.strength(of: password) == .strong)
    }

    @Test func eightCharAllTypesIsMedium() {
        let password = "aB1!eG5@"  // 8 × log2(87) ≈ 51.5
        #expect(PasswordStrengthCalculator.strength(of: password) == .medium)
    }

    @Test func thirtyTwoCharLowercaseIsStrong() {
        let password = String(repeating: "a", count: 32) // 32 × log2(26) ≈ 150.4
        #expect(PasswordStrengthCalculator.strength(of: password) == .strong)
    }

    // MARK: - Generation Invariants (deterministic despite randomness)

    @Test func twelveCharAllTypesGeneratedIsAlwaysStrong() {
        for _ in 0..<50 {
            let password = PasswordGenerator.generate(length: 12)
            #expect(PasswordStrengthCalculator.strength(of: password) == .strong)
        }
    }

    @Test func fourCharAllTypesGeneratedIsAlwaysWeak() {
        for _ in 0..<50 {
            let password = PasswordGenerator.generate(length: 4)
            #expect(PasswordStrengthCalculator.strength(of: password) == .weak)
        }
    }

    @Test func twelveCharLowercaseOnlyGeneratedIsAlwaysMedium() {
        for _ in 0..<50 {
            let password = PasswordGenerator.generate(
                length: 12,
                useUppercase: false,
                useLowercase: true,
                useNumbers: false,
                useSymbols: false
            )
            #expect(PasswordStrengthCalculator.strength(of: password) == .medium)
        }
    }
}
