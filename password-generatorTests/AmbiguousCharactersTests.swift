//
//  AmbiguousCharactersTests.swift
//  password-generatorTests
//
//  Created by Stone Fuglaar on 8/14/26.
//

import Testing
@testable import password_generator

struct AmbiguousCharactersTests {

    // MARK: - Ambiguous Set Definition

    @Test func ambiguousSetContainsCoreCharacters() {
        let set = PasswordGenerator.ambiguous
        #expect(set.contains("0"))
        #expect(set.contains("O"))
        #expect(set.contains("o"))
        #expect(set.contains("1"))
        #expect(set.contains("l"))
        #expect(set.contains("I"))
    }

    @Test func ambiguousSetContainsConfusableSymbols() {
        let set = PasswordGenerator.ambiguous
        #expect(set.contains("|"))
        #expect(set.contains("'"))
        #expect(set.contains("["))
        #expect(set.contains("]"))
        #expect(set.contains("{"))
        #expect(set.contains("}"))
        #expect(set.contains(";"))
        #expect(set.contains(":"))
        #expect(set.contains(","))
        #expect(set.contains("."))
        #expect(set.contains("<"))
        #expect(set.contains(">"))
        #expect(set.contains("?"))
        #expect(set.contains("/"))
    }

    // MARK: - ambiguousFree

    @Test func ambiguousFreeRemovesUppercaseAmbiguity() {
        let filtered = PasswordGenerator.ambiguousFree(PasswordGenerator.uppercase)
        #expect(!filtered.contains("I"))
        #expect(!filtered.contains("O"))
        #expect(filtered.contains("A"))
        #expect(filtered.contains("Z"))
    }

    @Test func ambiguousFreeRemovesLowercaseAmbiguity() {
        let filtered = PasswordGenerator.ambiguousFree(PasswordGenerator.lowercase)
        #expect(!filtered.contains("l"))
        #expect(!filtered.contains("o"))
        #expect(filtered.contains("a"))
        #expect(filtered.contains("z"))
    }

    @Test func ambiguousFreeRemovesNumberAmbiguity() {
        let filtered = PasswordGenerator.ambiguousFree(PasswordGenerator.numbers)
        #expect(!filtered.contains("0"))
        #expect(!filtered.contains("1"))
        #expect(filtered == "23456789")
    }

    @Test func ambiguousFreeRemovesSymbolAmbiguity() {
        let filtered = PasswordGenerator.ambiguousFree(PasswordGenerator.symbols)
        #expect(!filtered.contains("|"))
        #expect(!filtered.contains("'"))
        #expect(!filtered.contains("["))
        #expect(!filtered.contains("]"))
        #expect(!filtered.contains("{"))
        #expect(!filtered.contains("}"))
        #expect(!filtered.contains(";"))
        #expect(!filtered.contains(":"))
        #expect(!filtered.contains(","))
        #expect(!filtered.contains("."))
        #expect(!filtered.contains("<"))
        #expect(!filtered.contains(">"))
        #expect(!filtered.contains("?"))
        #expect(!filtered.contains("/"))
        #expect(filtered.contains("!"))
        #expect(filtered.contains("@"))
        #expect(filtered.contains("="))
    }

    @Test func ambiguousFreeLeavesUnambiguousCharacters() {
        let filtered = PasswordGenerator.ambiguousFree(PasswordGenerator.lowercase)
        #expect(filtered.contains("m"))
        #expect(filtered.contains("t"))
    }

    // MARK: - Generation With Exclusion

    @Test func excludedGenerationContainsNoAmbiguousCharacters() {
        let password = PasswordGenerator.generate(
            length: 32,
            excludeAmbiguous: true
        )
        #expect(password.allSatisfy { !PasswordGenerator.ambiguous.contains($0) })
    }

    @Test func excludedGenerationPreservesLength() {
        for length in [4, 12, 32] {
            let password = PasswordGenerator.generate(
                length: length,
                excludeAmbiguous: true
            )
            #expect(password.count == length)
        }
    }

    @Test func excludedGenerationStillCoversEachType() {
        let password = PasswordGenerator.generate(
            length: 32,
            excludeAmbiguous: true
        )
        #expect(password.contains { $0.isUppercase })
        #expect(password.contains { $0.isLowercase })
        #expect(password.contains { $0.isNumber })
        #expect(password.contains { PasswordGenerator.symbols.contains($0) })
    }

    @Test func excludedNumbersOnlyUsesUnambiguousDigits() {
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: false,
            useLowercase: false,
            useNumbers: true,
            useSymbols: false,
            excludeAmbiguous: true
        )
        let digits = PasswordGenerator.ambiguousFree(PasswordGenerator.numbers)
        #expect(password.allSatisfy { digits.contains($0) })
    }

    @Test func excludedUppercaseOnlyHasNoIOrO() {
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: true,
            useLowercase: false,
            useNumbers: false,
            useSymbols: false,
            excludeAmbiguous: true
        )
        #expect(!password.contains("I"))
        #expect(!password.contains("O"))
        #expect(password.allSatisfy { $0.isUppercase })
    }

    @Test func excludedLowercaseOnlyHasNoLOrO() {
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: false,
            useLowercase: true,
            useNumbers: false,
            useSymbols: false,
            excludeAmbiguous: true
        )
        #expect(!password.contains("l"))
        #expect(!password.contains("o"))
        #expect(password.allSatisfy { $0.isLowercase })
    }

    @Test func excludedSymbolsOnlyUsesUnambiguousSymbols() {
        let password = PasswordGenerator.generate(
            length: 20,
            useUppercase: false,
            useLowercase: false,
            useNumbers: false,
            useSymbols: true,
            excludeAmbiguous: true
        )
        let symbols = PasswordGenerator.ambiguousFree(PasswordGenerator.symbols)
        #expect(password.allSatisfy { symbols.contains($0) })
    }

    @Test func exclusionDoesNotChangeGenerationWithoutFlag() {
        let password = PasswordGenerator.generate()
        #expect(password.count == 12)
    }

    // MARK: - Exclusion Changes Behavior

    @Test func unexcludedGenerationCanProduceAmbiguousCharacters() {
        let ambiguous = PasswordGenerator.ambiguous
        var sawAmbiguous = false
        for _ in 0..<200 {
            let password = PasswordGenerator.generate(length: 12)
            if password.contains(where: { ambiguous.contains($0) }) {
                sawAmbiguous = true
                break
            }
        }
        #expect(sawAmbiguous)
    }
}
