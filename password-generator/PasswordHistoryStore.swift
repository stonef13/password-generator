//
//  PasswordHistoryStore.swift
//  password-generator
//
//  Created by Stone Fuglaar on 8/12/26.
//

import Foundation
import Combine

struct PasswordHistoryItem: Identifiable, Equatable {
    let id: UUID
    let password: String
    let createdAt: Date
    var isFavorite: Bool

    init(id: UUID = UUID(), password: String, createdAt: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.password = password
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
}

extension PasswordHistoryItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id, password, createdAt, isFavorite
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        password = try container.decode(String.self, forKey: .password)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isFavorite = (try? container.decode(Bool.self, forKey: .isFavorite)) ?? false
    }
}

final class PasswordHistoryStore: ObservableObject {

    static let maxEntries = 10

    @Published private(set) var entries: [PasswordHistoryItem] = []

    private let defaults: UserDefaults
    private static let storageKey = "passwordHistory"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func add(_ password: String) {
        guard !password.isEmpty else { return }
        guard entries.first?.password != password else { return }

        entries.insert(PasswordHistoryItem(password: password), at: 0)
        if entries.count > Self.maxEntries {
            entries = Array(entries.prefix(Self.maxEntries))
        }
        save()
    }

    func toggleFavorite(id: UUID) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index].isFavorite.toggle()
        save()
    }

    var favorites: [PasswordHistoryItem] {
        entries.filter(\.isFavorite)
    }

    func remove(_ item: PasswordHistoryItem) {
        entries.removeAll { $0.id == item.id }
        save()
    }

    func clear() {
        entries = []
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: Self.storageKey) else { return }
        do {
            entries = try JSONDecoder().decode([PasswordHistoryItem].self, from: data)
        } catch {
            entries = []
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
