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

    private func copyButton(_ app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)["HistoryRow_0"]
    }

    private func starButton(_ app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)["FavoriteButton_Recent_0"]
    }

    private func favoritesHeader(_ app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)["FavoritesSectionHeader"]
    }

    // MARK: - Star button exists on history rows

    @MainActor
    func testStarButtonExistsOnHistoryRow() {
        let app = makeApp()
        openHistoryTab(in: app)

        XCTAssertTrue(copyButton(app).waitForExistence(timeout: 5))
        XCTAssertTrue(starButton(app).waitForExistence(timeout: 5))
    }

    // MARK: - Tapping star toggles favorite state

    @MainActor
    func testTappingStarMarksAsFavorite() {
        let app = makeApp()
        openHistoryTab(in: app)

        let starButton = starButton(app)
        XCTAssertTrue(starButton.waitForExistence(timeout: 5))
        starButton.tap()

        XCTAssertTrue(favoritesHeader(app).waitForExistence(timeout: 5))
    }

    @MainActor
    func testTappingStarTwiceUnfavorites() {
        let app = makeApp()
        openHistoryTab(in: app)

        let starButton = starButton(app)
        XCTAssertTrue(starButton.waitForExistence(timeout: 5))
        starButton.tap()
        starButton.tap()

        XCTAssertFalse(favoritesHeader(app).waitForExistence(timeout: 2))
    }

    // MARK: - Favorite appears in Favorites section

    @MainActor
    func testFavoritedPasswordAppearsInFavoritesSection() {
        let app = makeApp()
        openHistoryTab(in: app)

        let starButton = starButton(app)
        XCTAssertTrue(starButton.waitForExistence(timeout: 5))
        starButton.tap()

        XCTAssertTrue(favoritesHeader(app).waitForExistence(timeout: 5))
    }

    // MARK: - Favorites persist across relaunch

    @MainActor
    func testFavoritesPersistAcrossLaunch() {
        let app = makeApp()
        openHistoryTab(in: app)

        let starButton = starButton(app)
        XCTAssertTrue(starButton.waitForExistence(timeout: 5))
        starButton.tap()
        XCTAssertTrue(favoritesHeader(app).waitForExistence(timeout: 5))

        app.terminate()

        let relaunched = XCUIApplication()
        relaunched.launch()
        relaunched.tabBars.buttons["History"].tap()

        XCTAssertTrue(favoritesHeader(relaunched).waitForExistence(timeout: 5))
    }

    // MARK: - Star tap does not show copy toast

    @MainActor
    func testStarTapDoesNotShowCopiedToast() {
        let app = makeApp()
        openHistoryTab(in: app)

        let starButton = starButton(app)
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

        let firstRow = copyButton(app)
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        firstRow.tap()

        let toast = app.descendants(matching: .any)["CopiedToast"]
        XCTAssertTrue(toast.waitForExistence(timeout: 5))
    }
}