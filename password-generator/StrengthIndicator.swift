//
//  StrengthIndicator.swift
//  password-generator
//
//  Created by Stone Fuglaar on 8/18/26.
//

import SwiftUI

struct StrengthIndicator: View {
    let strength: PasswordStrength

    private var color: Color {
        switch strength {
        case .weak:   return .red
        case .medium: return .yellow
        case .strong: return .green
        }
    }

    var body: some View {
        Text(strength.rawValue)
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(color, in: Capsule())
            .accessibilityIdentifier("StrengthIndicator")
    }
}

#Preview {
    VStack {
        ForEach(PasswordStrength.allCases, id: \.self) { s in
            StrengthIndicator(strength: s)
        }
    }
}
