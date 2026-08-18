//
//  FavoritesTests.swift
//  password-generatorTests
//
//  Created by Stone Fuglaar on 8/18/26.
//

import Foundation
import Testing
@testable import password_generator

struct FavoritesTests {

    private func makeStore() -> (store: PasswordHistoryStore, defaults: UserDefaults, suiteName: String) {
        let suiteName = "FavoritesTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store = PasswordHistoryStore(defaults: defaults)
        return (store, defaults, suiteName)
    }

    // MARK: - Toggle Favorite

    @Test func toggleFavoriteSetsIsFavoriteTrue() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("Abc123!x")
        let item = store.entries[0]
        store.toggleFavorite(id: item.id)
        #expect(store.entries[0].isFavorite == true)
    }

    @Test func toggleFavoriteTwiceReverts() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("Abc123!x")
        let item = store.entries[0]
        store.toggleFavorite(id: item.id)
        store.toggleFavorite(id: item.id)
        #expect(store.entries[0].isFavorite == false)
    }

    @Test func toggleFavoriteUnknownIdIsNoop() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("Abc123!x")
        store.toggleFavorite(id: UUID())
        #expect(store.entries[0].isFavorite == false)
    }

    // MARK: - Favorites Computed Property

    @Test func favoritesReturnsOnlyFavorited() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("first")
        store.add("second")
        store.add("third")
        store.toggleFavorite(id: store.entries[1].id)

        #expect(store.favorites.count == 1)
        #expect(store.favorites[0].password == "second")
    }

    @Test func favoritesPreservesNewestFirstOrder() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("first")
        store.add("second")
        store.add("third")
        store.toggleFavorite(id: store.entries[2].id)
        store.toggleFavorite(id: store.entries[0].id)

        #expect(store.favorites.map(\.password) == ["third", "first"])
    }

    @Test func favoritesIsEmptyWhenNoneFavorited() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("Abc123!x")
        #expect(store.favorites.isEmpty)
    }

    // MARK: - Persistence

    @Test func favoritesPersistAcrossStoreInstances() {
        let suiteName = "FavoritesTests-\(UUID().uuidString)"
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }
        let defaults = UserDefaults(suiteName: suiteName)!

        let firstStore = PasswordHistoryStore(defaults: defaults)
        firstStore.add("favorited-pw")
        firstStore.toggleFavorite(id: firstStore.entries[0].id)

        let reloadedStore = PasswordHistoryStore(defaults: defaults)
        #expect(reloadedStore.entries[0].isFavorite == true)
        #expect(reloadedStore.favorites.count == 1)
        #expect(reloadedStore.favorites[0].password == "favorited-pw")
    }

    // MARK: - Migration: old JSON without isFavorite decodes with isFavorite == false

    @Test func decodeOldFormatWithoutIsFavorite() {
        let suiteName = "FavoritesTests-\(UUID().uuidString)"
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }
        let defaults = UserDefaults(suiteName: suiteName)!

        let oldItem: [String: Any] = [
            "id": UUID().uuidString,
            "password": "old-password",
            "createdAt": Date(timeIntervalSince1970: 1_700_000_000)
        ]
        let data = try! JSONSerialization.data(withJSONObject: [oldItem])
        defaults.set(data, forKey: "passwordHistory")

        let store = PasswordHistoryStore(defaults: defaults)
        #expect(store.entries.count == 1)
        #expect(store.entries[0].password == "old-password")
        #expect(store.entries[0].isFavorite == false)
    }

    // MARK: - Favorites count toward max entries cap

    @Test func favoritedEntryEvictedWhenCapExceeded() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("first")
        store.toggleFavorite(id: store.entries[0].id)

        for i in 0..<12 {
            store.add("password-\(i)")
        }
        #expect(store.entries.count == PasswordHistoryStore.maxEntries)
        #expect(store.favorites.isEmpty)
    }

    // MARK: - Clear / Remove with favorites

    @Test func clearRemovesFavorites() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("Abc123!x")
        store.toggleFavorite(id: store.entries[0].id)
        store.clear()
        #expect(store.entries.isEmpty)
        #expect(store.favorites.isEmpty)
    }

    @Test func removeFavoriteRemovesFromFavorites() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("first")
        store.add("second")
        store.toggleFavorite(id: store.entries[0].id)
        let favorited = store.entries[0]
        store.remove(favorited)
        #expect(store.favorites.isEmpty)
        #expect(store.entries.count == 1)
    }
}
