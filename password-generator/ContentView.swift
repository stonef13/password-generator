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
    @State private var excludeAmbiguous = false
    @State private var showToast = false
    @State private var toastTask: Task<Void, Never>?
    @State private var currentItemID: UUID?
    @StateObject private var historyStore = PasswordHistoryStore()

    private var currentStrength: PasswordStrength {
        PasswordStrengthCalculator.strength(of: currentPassword)
    }

    private var isCurrentFavorite: Bool {
        if let id = currentItemID,
           let entry = historyStore.entries.first(where: { $0.id == id }) {
            return entry.isFavorite
        }
        return historyStore.entries.first(where: { $0.password == currentPassword })?.isFavorite ?? false
    }

    var body: some View {
        TabView {
            generatorContent
                .tabItem {
                    Label("Generate", systemImage: "key")
                }

            HistoryView(store: historyStore)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("-resetHistory") {
                historyStore.clear()
            }
            generateAndRecord()
        }
        .onChange(of: passwordLength) { _, _ in
            regenerate()
        }
        .onChange(of: useUppercase) { _, _ in regenerate() }
        .onChange(of: useLowercase) { _, _ in regenerate() }
        .onChange(of: useNumbers) { _, _ in regenerate() }
        .onChange(of: useSymbols) { _, _ in regenerate() }
        .onChange(of: excludeAmbiguous) { _, _ in regenerate() }
    }

    private var generatorContent: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("PasswordGen")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(currentPassword)
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .accessibilityIdentifier("PasswordDisplay")

                StrengthIndicator(strength: currentStrength)

                VStack(spacing: 8) {
                    CopyConfirmationBadge(show: showToast)
                    HStack(spacing: 8) {
                        Button {
                            toggleFavoriteCurrent()
                        } label: {
                            Image(systemName: isCurrentFavorite ? "star.fill" : "star")
                                .font(.title2)
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(.bordered)
                        .tint(.yellow)
                        .accessibilityLabel(isCurrentFavorite ? "Unfavorite current password" : "Favorite current password")
                        .accessibilityIdentifier("FavoriteCurrentButton")

                        Button {
                            Task { await ClipboardManager.copyToClipboard(currentPassword) }
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
                        .accessibilityIdentifier("CopyButton")
                    }
                }
                .padding(.horizontal)

                VStack(spacing: 8) {
                    Text("Password Length: \(Int(passwordLength))")
                        .font(.headline)

                    Slider(value: $passwordLength, in: 4...32, step: 1)
                }
                .padding(.horizontal)

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
                .tint(.accentColor)
                .padding(.horizontal)

                VStack(spacing: 8) {
                    Text("Advanced Options")
                        .font(.headline)
                    Toggle("Exclude Ambiguous Characters", isOn: $excludeAmbiguous)
                        .accessibilityIdentifier("ExcludeAmbiguousToggle")
                }
                .padding(.horizontal)

                Button {
                    generateAndRecord()
                } label: {
                    Text("Generate")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .accessibilityIdentifier("GenerateButton")
            }
            .padding(.vertical)
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
            useSymbols: useSymbols,
            excludeAmbiguous: excludeAmbiguous
        )
        currentItemID = historyStore.entries.first(where: { $0.password == currentPassword })?.id
    }

    private func generateAndRecord() {
        regenerate()
        historyStore.add(currentPassword)
        currentItemID = historyStore.entries.first(where: { $0.password == currentPassword })?.id
    }

    private func toggleFavoriteCurrent() {
        guard !currentPassword.isEmpty else { return }
        if let id = currentItemID,
           historyStore.entries.contains(where: { $0.id == id }) {
            historyStore.toggleFavorite(id: id)
            return
        }
        if let entry = historyStore.entries.first(where: { $0.password == currentPassword }) {
            currentItemID = entry.id
            historyStore.toggleFavorite(id: entry.id)
            return
        }
        historyStore.add(currentPassword)
        if let entry = historyStore.entries.first(where: { $0.password == currentPassword }) {
            currentItemID = entry.id
            historyStore.toggleFavorite(id: entry.id)
        }
    }
}

#Preview {
    ContentView()
}
