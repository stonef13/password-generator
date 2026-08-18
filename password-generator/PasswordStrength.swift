//
//  PasswordStrength.swift
//  password-generator
//
//  Created by Stone Fuglaar on 8/18/26.
//

import Foundation

enum PasswordStrength: String, CaseIterable, Equatable {
    case weak = "Weak"
    case medium = "Medium"
    case strong = "Strong"
}

enum PasswordStrengthCalculator {

    private static let weakThreshold: Double = 45
    private static let strongThreshold: Double = 70

    static func strength(of password: String) -> PasswordStrength {
        guard !password.isEmpty else { return .weak }
        let e = entropy(of: password)
        if e < weakThreshold { return .weak }
        if e > strongThreshold { return .strong }
        return .medium
    }

    static func entropy(of password: String) -> Double {
        guard !password.isEmpty else { return 0 }
        let pool = Double(characterClassPoolSize(of: password))
        return Double(password.count) * log2(pool)
    }

    static func characterClassPoolSize(of password: String) -> Int {
        var size = 0
        if password.contains(where: { $0.isUppercase }) { size += 26 }
        if password.contains(where: { $0.isLowercase }) { size += 26 }
        if password.contains(where: { $0.isNumber })     { size += 10 }
        if password.contains(where: { PasswordGenerator.symbols.contains($0) }) {
            size += PasswordGenerator.symbols.count
        }
        return size
    }
}
