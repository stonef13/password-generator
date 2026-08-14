//
//  AmbiguousCharactersUITests.swift
//  password-generatorUITests
//
//  Created by Stone Fuglaar on 8/14/26.
//

import XCTest

final class AmbiguousCharactersUITests: XCTestCase {

    private let ambiguous = "0O1lIo|'[]{};:,.<>?/"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-resetHistory"]
        app.launch()
        return app
    }

    @MainActor
    func testExcludeAmbiguousToggleExists() {
        let app = makeApp()
        XCTAssertTrue(app.switches["ExcludeAmbiguousToggle"].exists)
    }

    @MainActor
    func testToggleOnRegeneratesPasswordWithoutAmbiguousCharacters() {
        let app = makeApp()
        let display = app.staticTexts["PasswordDisplay"]
        XCTAssertTrue(display.waitForExistence(timeout: 10))
        let original = display.label

        let toggle = app.switches["ExcludeAmbiguousToggle"]
        XCTAssertTrue(toggle.exists)
        toggle.tap()

        let regenerated = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label != %@", original),
            object: display
        )
        XCTAssertEqual(XCTWaiter.wait(for: [regenerated], timeout: 5), .completed)

        let label = display.label
        XCTAssertFalse(label.isEmpty)
        for character in ambiguous {
            XCTAssertFalse(label.contains(String(character)), "Password contains ambiguous character \(character)")
        }
    }
}
