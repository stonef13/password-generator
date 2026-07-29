//
//  ContentView.swift
//  password-generator
//
//  Created by Stone Fuglaar on 7/28/26.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPassword = ""
    @State private var passwordLength: Double = 12

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("PasswordGen")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 8) {
                Text("Password Length: \(Int(passwordLength))")
                    .font(.headline)

                Slider(value: $passwordLength, in: 4...32, step: 1)
                    .padding(.horizontal)
            }

            Text(currentPassword)
                .font(.system(size: 28, weight: .medium, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

            Button {
                currentPassword = PasswordGenerator.generate(length: Int(passwordLength))
            } label: {
                Text("Generate")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer()
            Spacer()
        }
        .onAppear {
            currentPassword = PasswordGenerator.generate(length: Int(passwordLength))
        }
        .onChange(of: passwordLength) { _, _ in
            currentPassword = PasswordGenerator.generate(length: Int(passwordLength))
        }
    }
}

#Preview {
    ContentView()
}
