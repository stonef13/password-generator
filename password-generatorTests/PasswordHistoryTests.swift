//
//  PasswordHistoryTests.swift
//  password-generatorTests
//
//  Created by Stone Fuglaar  on 8/12/26.
//

import Foundation
import Testing
@testable import password_generator

struct PasswordHistoryTests {

    private func makeStore() -> (store: PasswordHistoryStore, defaults: UserDefaults, suiteName: String) {
        let suiteName = "PasswordHistoryTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store = PasswordHistoryStore(defaults: defaults)
        return (store, defaults, suiteName)
    }

    // MARK: - Adding Entries

    @Test func addStoresEntryWithTimestamp() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("Abc123!x")
        #expect(store.entries.count == 1)
        #expect(store.entries.first?.password == "Abc123!x")
        #expect(store.entries.first?.createdAt != nil)
        #expect(abs(store.entries.first!.createdAt.timeIntervalSinceNow) < 5)
    }

    @Test func maintainsNewestFirstOrdering() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("first")
        store.add("second")
        store.add("third")
        #expect(store.entries.map(\.password) == ["third", "second", "first"])
    }

    @Test func capsAtTenEntries() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        for i in 0..<12 {
            store.add("password-\(i)")
        }
        #expect(store.entries.count == PasswordHistoryStore.maxEntries)
        #expect(store.entries.first?.password == "password-11")
        #expect(store.entries.last?.password == "password-2")
        #expect(store.entries.map(\.password).contains("password-1") == false)
        #expect(store.entries.map(\.password).contains("password-0") == false)
    }

    @Test func ignoresConsecutiveDuplicatePassword() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("same")
        store.add("same")
        #expect(store.entries.count == 1)
    }

    @Test func ignoresEmptyPassword() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("")
        #expect(store.entries.isEmpty)
    }

    // MARK: - Removal

    @Test func removeDeletesSingleEntry() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("first")
        store.add("second")
        let second = store.entries.first!
        store.remove(second)
        #expect(store.entries.map(\.password) == ["first"])
    }

    @Test func clearEmptiesHistory() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        store.add("first")
        store.add("second")
        store.clear()
        #expect(store.entries.isEmpty)
    }

    // MARK: - Persistence

    @Test func persistsAcrossStoreInstances() {
        let suiteName = "PasswordHistoryTests-\(UUID().uuidString)"
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }
        let defaults = UserDefaults(suiteName: suiteName)!

        let firstStore = PasswordHistoryStore(defaults: defaults)
        firstStore.add("persisted-password")

        let reloadedStore = PasswordHistoryStore(defaults: defaults)
        #expect(reloadedStore.entries.count == 1)
        #expect(reloadedStore.entries.first?.password == "persisted-password")
        #expect(abs(reloadedStore.entries.first!.createdAt.timeIntervalSinceNow) < 5)
    }

    @Test func decodeRoundTripPreservesPasswordAndDate() {
        let suiteName = "PasswordHistoryTests-\(UUID().uuidString)"
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }
        let defaults = UserDefaults(suiteName: suiteName)!

        let expected = PasswordHistoryItem(password: "roundtrip", createdAt: Date(timeIntervalSince1970: 1_700_000_000))
        let data = try! JSONEncoder().encode([expected])
        defaults.set(data, forKey: "passwordHistory")

        let store = PasswordHistoryStore(defaults: defaults)
        #expect(store.entries.count == 1)
        #expect(store.entries.first?.password == "roundtrip")
        #expect(store.entries.first?.createdAt == expected.createdAt)
    }

    // MARK: - Error Handling

    @Test func gracefullyHandlesCorruptJSON() {
        let suiteName = "PasswordHistoryTests-\(UUID().uuidString)"
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.set(Data("not valid json".utf8), forKey: "passwordHistory")

        let store = PasswordHistoryStore(defaults: defaults)
        #expect(store.entries.isEmpty)
    }

    @Test func missingDataLoadsEmpty() {
        let (store, _, suiteName) = makeStore()
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }

        #expect(store.entries.isEmpty)
    }
}
