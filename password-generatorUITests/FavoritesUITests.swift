//
//  FavoritesUITests.swift
//  password-generatorUITests
//
//  Created by Stone Fuglaar on 8/18/26.
//

import XCTest

final class FavoritesUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-resetHistory"]
        app.launch()
        return app
    }

    private func openHistoryTab(in app: XCUIApplication) {
        app.tabBars.buttons["History"].tap()
    }

    private func generatePasswords(_ app: XCUIApplication, count: Int = 3) {
        for _ in 0..<count {
            app.buttons["GenerateButton"].tap()
        }
    }

    // MARK: - Star button exists on history rows

    @MainActor
    func testStarButtonExistsOnHistoryRow() {
        let app = makeApp()
        openHistoryTab(in: app)
        let firstRow = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'HistoryRow_'")).firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        let starButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'FavoriteButton_'")).firstMatch
        XCTAssertTrue(starButton.waitForExistence(timeout: 5))
    }

    // MARK: - Tapping star toggles favorite state

    @MainActor
    func testTappingStarMarksAsFavorite() {
        let app = makeApp()
        openHistoryTab(in: app)
        let starButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'FavoriteButton_'")).firstMatch
        XCTAssertTrue(starButton.waitForExistence(timeout: 5))
        starButton.tap()

        let favoritesSection = app.otherElements["FavoritesSection"]
        XCTAssertTrue(favoritesSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testTappingStarTwiceUnfavorites() {
        let app = makeApp()
        openHistoryTab(in: app)
        let starButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'FavoriteButton_'")).firstMatch
        XCTAssertTrue(starButton.waitForExistence(timeout: 5))
        starButton.tap()
        starButton.tap()

        let favoritesSection = app.otherElements["FavoritesSection"]
        XCTAssertFalse(favoritesSection.waitForExistence(timeout: 2))
    }

    // MARK: - Favorite appears in Favorites section

    @MainActor
    func testFavoritedPasswordAppearsInFavoritesSection() {
        let app = makeApp()
        generatePasswords(app, count: 3)
        openHistoryTab(in: app)

        let starButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'FavoriteButton_Recent'")).firstMatch
        XCTAssertTrue(starButton.waitForExistence(timeout: 5))
        starButton.tap()

        let favoritesSection = app.otherElements["FavoritesSection"]
        XCTAssertTrue(favoritesSection.waitForExistence(timeout: 5))
    }

    // MARK: - Favorites persist across relaunch

    @MainActor
    func testFavoritesPersistAcrossLaunch() {
        let app = makeApp()
        generatePasswords(app, count: 3)
        openHistoryTab(in: app)

        let starButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'FavoriteButton_Recent'")).firstMatch
        XCTAssertTrue(starButton.waitForExistence(timeout: 5))
        starButton.tap()

        let favoritesSection = app.otherElements["FavoritesSection"]
        XCTAssertTrue(favoritesSection.waitForExistence(timeout: 5))

        app.terminate()

        let relaunched = XCUIApplication()
        relaunched.launch()
        relaunched.tabBars.buttons["History"].tap()

        let relaunchedFavorites = relaunched.otherElements["FavoritesSection"]
        XCTAssertTrue(relaunchedFavorites.waitForExistence(timeout: 5))
    }

    // MARK: - Star tap does not show copy toast

    @MainActor
    func testStarTapDoesNotShowCopiedToast() {
        let app = makeApp()
        openHistoryTab(in: app)
        let starButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'FavoriteButton_'")).firstMatch
        XCTAssertTrue(starButton.waitForExistence(timeout: 5))
        starButton.tap()

        let toast = app.descendants(matching: .any)["CopiedToast"]
        XCTAssertFalse(toast.waitForExistence(timeout: 1))
    }

    // MARK: - Tapping row body still copies (toast appears)

    @MainActor
    func testTappingRowBodyShowsCopiedToast() {
        let app = makeApp()
        openHistoryTab(in: app)
        let firstRow = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'HistoryRow_'")).firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        firstRow.tap()

        let toast = app.descendants(matching: .any)["CopiedToast"]
        XCTAssertTrue(toast.waitForExistence(timeout: 5))
    }
}
