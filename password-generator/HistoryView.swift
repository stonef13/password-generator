//
//  HistoryView.swift
//  password-generator
//
//  Created by Stone Fuglaar on 8/12/26.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: PasswordHistoryStore
    @State private var showToast = false
    @State private var toastTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            Group {
                if store.entries.isEmpty {
                    ContentUnavailableView(
                        "No passwords yet",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Generated passwords will appear here.")
                    )
                    .accessibilityIdentifier("HistoryEmptyState")
                } else {
                    List {
                        ForEach(Array(store.entries.enumerated()), id: \.element.id) { index, item in
                            Button {
                                copy(item.password)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.password)
                                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("HistoryRow_\(index)")
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                store.remove(store.entries[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
        .safeAreaInset(edge: .bottom) {
            if !store.entries.isEmpty {
                Button("Clear History") {
                    store.clear()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .padding(.horizontal)
                .accessibilityIdentifier("ClearHistoryButton")
            }
        }
        .overlay {
            CopyConfirmationBadge(show: showToast)
        }
    }

    private func copy(_ password: String) {
        Task { await ClipboardManager.copyToClipboard(password) }
        showToast = true
        toastTask?.cancel()
        toastTask = Task {
            try? await Task.sleep(for: .seconds(2))
            showToast = false
        }
    }
}
