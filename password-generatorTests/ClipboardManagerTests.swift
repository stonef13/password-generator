//
//  ClipboardManagerTests.swift
//  password-generatorTests
//
//  Created by Stone Fuglaar on 7/28/26.
//

import Testing
import UIKit
@testable import password_generator

struct ClipboardManagerTests {

    @Test func copyToClipboardSetsContent() async {
        let testString = "TestPassword123!"
        await ClipboardManager.copyToClipboard(testString)
        #expect(ClipboardManager.clipboardContent() == testString)
    }

    @Test func clipboardContentReturnsNilWhenEmpty() {
        UIPasteboard.general.string = nil
        #expect(ClipboardManager.clipboardContent() == nil)
    }

    @Test func clipboardOverwritesPreviousContent() async {
        await ClipboardManager.copyToClipboard("first")
        await ClipboardManager.copyToClipboard("second")
        #expect(ClipboardManager.clipboardContent() == "second")
    }

    @Test func clipboardHandlesEmptyString() async {
        await ClipboardManager.copyToClipboard("")
        #expect(ClipboardManager.clipboardContent() == "")
    }
}
