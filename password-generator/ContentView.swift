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
    @State private var useUppercase = true
    @State private var useLowercase = true
    @State private var useNumbers = true
    @State private var useSymbols = true
    @State private var showToast = false
    @State private var toastTask: Task<Void, Never>?

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

            VStack(spacing: 8) {
                Text("Character Types")
                    .font(.headline)
                Toggle("Uppercase (A-Z)", isOn: $useUppercase)
                    .disabled(useUppercase && !useLowercase && !useNumbers && !useSymbols)
                Toggle("Lowercase (a-z)", isOn: $useLowercase)
                    .disabled(useLowercase && !useUppercase && !useNumbers && !useSymbols)
                Toggle("Numbers (0-9)", isOn: $useNumbers)
                    .disabled(useNumbers && !useUppercase && !useLowercase && !useSymbols)
                Toggle("Symbols (!@#$)", isOn: $useSymbols)
                    .disabled(useSymbols && !useUppercase && !useLowercase && !useNumbers)
            }
            .padding(.horizontal)

            Text(currentPassword)
                .font(.system(size: 28, weight: .medium, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .accessibilityIdentifier("PasswordDisplay")

            Button {
                ClipboardManager.copyToClipboard(currentPassword)
                showToast = true
                toastTask?.cancel()
                toastTask = Task {
                    try? await Task.sleep(for: .seconds(2))
                    showToast = false
                }
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .accessibilityIdentifier("CopyButton")

            Button {
                regenerate()
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
            regenerate()
        }
        .onChange(of: passwordLength) { _, _ in
            regenerate()
        }
        .onChange(of: useUppercase) { _, _ in regenerate() }
        .onChange(of: useLowercase) { _, _ in regenerate() }
        .onChange(of: useNumbers) { _, _ in regenerate() }
        .onChange(of: useSymbols) { _, _ in regenerate() }
        .overlay {
            if showToast {
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
                .animation(.easeIn, value: showToast)
            }
        }
    }

    private func regenerate() {
        guard PasswordGenerator.canGenerate(
            useUppercase: useUppercase,
            useLowercase: useLowercase,
            useNumbers: useNumbers,
            useSymbols: useSymbols
        ) else { return }
        currentPassword = PasswordGenerator.generate(
            length: Int(passwordLength),
            useUppercase: useUppercase,
            useLowercase: useLowercase,
            useNumbers: useNumbers,
            useSymbols: useSymbols
        )
    }
}

#Preview {
    ContentView()
}
