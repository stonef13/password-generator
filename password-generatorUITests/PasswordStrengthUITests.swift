//
//  PasswordStrengthUITests.swift
//  password-generatorUITests
//
//  Created by Stone Fuglaar on 8/18/26.
//

import XCTest

final class PasswordStrengthUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-resetHistory"]
        app.launch()
        return app
    }

    // MARK: - Indicator Exists

    @MainActor
    func testStrengthIndicatorExists() {
        let app = makeApp()
        let indicator = app.staticTexts["StrengthIndicator"]
        XCTAssertTrue(indicator.waitForExistence(timeout: 5))
    }

    // MARK: - Default State Is Strong

    @MainActor
    func testDefaultPasswordIsStrong() {
        let app = makeApp()
        let indicator = app.staticTexts["StrengthIndicator"]
        XCTAssertTrue(indicator.waitForExistence(timeout: 5))
        XCTAssertEqual(indicator.label, "Strong")
    }

    // MARK: - Minimum Length Is Weak

    @MainActor
    func testSliderAt4IsWeak() {
        let app = makeApp()
        let indicator = app.staticTexts["StrengthIndicator"]
        XCTAssertTrue(indicator.waitForExistence(timeout: 5))

        let slider = app.sliders.firstMatch
        XCTAssertTrue(slider.exists)
        slider.adjust(toNormalizedSliderPosition: 0)

        let weakExpectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label == %@", "Weak"),
            object: indicator
        )
        XCTAssertEqual(XCTWaiter.wait(for: [weakExpectation], timeout: 5), .completed)
    }

    // MARK: - Single Class Medium

    @MainActor
    func testLowercaseOnlyIsMedium() {
        let app = makeApp()
        let indicator = app.staticTexts["StrengthIndicator"]
        XCTAssertTrue(indicator.waitForExistence(timeout: 5))

        app.switches["Uppercase (A-Z)"].tap()
        app.switches["Numbers (0-9)"].tap()
        app.switches["Symbols (!@#$)"].tap()

        let mediumExpectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label == %@", "Medium"),
            object: indicator
        )
        XCTAssertEqual(XCTWaiter.wait(for: [mediumExpectation], timeout: 5), .completed)
    }

    // MARK: - Long Password Strong

    @MainActor
    func testSliderAt32IsStrong() {
        let app = makeApp()
        let indicator = app.staticTexts["StrengthIndicator"]
        XCTAssertTrue(indicator.waitForExistence(timeout: 5))

        let slider = app.sliders.firstMatch
        XCTAssertTrue(slider.exists)
        slider.adjust(toNormalizedSliderPosition: 1)

        let strongExpectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label == %@", "Strong"),
            object: indicator
        )
        XCTAssertEqual(XCTWaiter.wait(for: [strongExpectation], timeout: 5), .completed)
    }
}
