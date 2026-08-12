//
//  password_generatorUITests.swift
//  password-generatorUITests
//
//  Created by Stone Fuglaar  on 7/28/26.
//

import XCTest

final class password_generatorUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // MARK: - US-4: Copy Password to Clipboard

    @MainActor
    func testCopyButtonExists() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["CopyButton"].exists)
    }

    @MainActor
    func testCopyButtonShowsToast() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["CopyButton"].tap()
        let toast = app.descendants(matching: .any)["CopiedToast"]
        XCTAssertTrue(toast.waitForExistence(timeout: 5))
    }

    @MainActor
    func testToastDisappearsAfter2Seconds() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["CopyButton"].tap()
        let toast = app.descendants(matching: .any)["CopiedToast"]
        XCTAssertTrue(toast.waitForExistence(timeout: 5))
        let gone = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: toast
        )
        XCTAssertEqual(XCTWaiter.wait(for: [gone], timeout: 6), .completed)
    }

    @MainActor
    func testPasswordCopiedToClipboard() {
        let app = XCUIApplication()
        app.launch()
        let passwordText = app.staticTexts["PasswordDisplay"]
        XCTAssertTrue(passwordText.waitForExistence(timeout: 10))
        XCTAssertFalse(passwordText.label.isEmpty)
        app.buttons["CopyButton"].tap()
        // Clipboard content itself is verified in ClipboardManagerTests: reading
        // UIPasteboard from the UI test runner deadlocks (semaphore wait in
        // UIPasteboard.string), so UI tests only verify the copy flow.
    }
}
