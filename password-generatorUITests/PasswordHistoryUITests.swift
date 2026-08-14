//
//  PasswordHistoryUITests.swift
//  password-generatorUITests
//
//  Created by Stone Fuglaar  on 8/12/26.
//

import XCTest

final class PasswordHistoryUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func makeApp(resetHistory: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        if resetHistory {
            app.launchArguments = ["-resetHistory"]
        }
        app.launch()
        return app
    }

    private func openHistoryTab(in app: XCUIApplication) {
        app.tabBars.buttons["History"].tap()
    }

    // MARK: - US-5: View Password History

    @MainActor
    func testHistoryTabExists() {
        let app = makeApp()
        XCTAssertTrue(app.tabBars.buttons["History"].exists)
    }

    @MainActor
    func testGeneratedPasswordAppearsInHistory() {
        let app = makeApp()
        let display = app.staticTexts["PasswordDisplay"]
        XCTAssertTrue(display.waitForExistence(timeout: 10))
        XCTAssertFalse(display.label.isEmpty)

        app.buttons["GenerateButton"].tap()
        let generatedPassword = app.staticTexts["PasswordDisplay"].label

        openHistoryTab(in: app)
        let firstRow = app.buttons["HistoryRow_0"]
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        XCTAssertTrue(firstRow.label.contains(generatedPassword))
    }

    @MainActor
    func testHistoryRowShowsTimestamp() {
        let app = makeApp()
        openHistoryTab(in: app)
        let firstRow = app.buttons["HistoryRow_0"]
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        XCTAssertTrue(firstRow.label.contains("at "))
    }

    @MainActor
    func testTapHistoryRowShowsCopiedToast() {
        let app = makeApp()
        openHistoryTab(in: app)
        let firstRow = app.buttons["HistoryRow_0"]
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        firstRow.tap()
        let toast = app.descendants(matching: .any)["CopiedToast"]
        XCTAssertTrue(toast.waitForExistence(timeout: 5))
    }

    @MainActor
    func testClearHistoryEmptiesList() {
        let app = makeApp()
        openHistoryTab(in: app)
        let firstRow = app.buttons["HistoryRow_0"]
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))

        let clearButton = app.buttons["ClearHistoryButton"]
        XCTAssertTrue(clearButton.exists)
        clearButton.tap()

        let emptyState = app.descendants(matching: .any)["HistoryEmptyState"]
        XCTAssertTrue(emptyState.waitForExistence(timeout: 5))
        XCTAssertFalse(firstRow.exists)
    }

    @MainActor
    func testHistoryPersistsAcrossLaunch() {
        let app = XCUIApplication()
        app.launchArguments = ["-resetHistory"]
        app.launch()
        openHistoryTab(in: app)
        XCTAssertTrue(app.buttons["HistoryRow_0"].waitForExistence(timeout: 5))

        app.terminate()

        let relaunched = XCUIApplication()
        relaunched.launch()
        openHistoryTab(in: relaunched)
        XCTAssertTrue(relaunched.buttons["HistoryRow_0"].waitForExistence(timeout: 5))
    }
}
