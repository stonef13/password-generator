//
//  CopyConfirmationBadge.swift
//  password-generator
//
//  Created by Stone Fuglaar on 8/12/26.
//

import SwiftUI

struct CopyConfirmationBadge: View {
    let show: Bool

    var body: some View {
        if show {
            VStack {
                Spacer()
                Text("Copied!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.black.opacity(0.8))
                    .cornerRadius(10)
                    .accessibilityIdentifier("CopiedToast")
                Spacer()
            }
            .animation(.easeIn, value: show)
            .transition(.opacity)
        }
    }
}
