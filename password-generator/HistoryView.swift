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
                        if !store.favorites.isEmpty {
                            Section {
                                ForEach(Array(store.favorites.enumerated()), id: \.element.id) { index, item in
                                    historyRow(item: item, index: index, section: "Favorites")
                                }
                                .onDelete { offsets in
                                    for index in offsets {
                                        store.remove(store.favorites[index])
                                    }
                                }
                            } header: {
                                Text("Favorites")
                                    .accessibilityIdentifier("FavoritesSectionHeader")
                            }
                        }

                        Section("Recent") {
                            ForEach(Array(store.entries.enumerated()), id: \.element.id) { index, item in
                                historyRow(item: item, index: index, section: "Recent")
                            }
                            .onDelete { offsets in
                                for index in offsets {
                                    store.remove(store.entries[index])
                                }
                            }
                        }
                        .accessibilityIdentifier("RecentSection")
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

    private func historyRow(item: PasswordHistoryItem, index: Int, section: String) -> some View {
        HStack {
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
            .buttonStyle(.borderless)
            .accessibilityIdentifier(section == "Recent" ? "HistoryRow_\(index)" : "FavoriteRow_\(index)")

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    store.toggleFavorite(id: item.id)
                }
            } label: {
                Image(systemName: item.isFavorite ? "star.fill" : "star")
                    .foregroundColor(item.isFavorite ? .yellow : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(item.isFavorite ? "Unfavorite" : "Favorite")
            .accessibilityIdentifier("FavoriteButton_\(section)_\(index)")
        }
        .accessibilityElement(children: .contain)
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
