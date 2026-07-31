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

    @Test func copyToClipboardSetsContent() {
        let testString = "TestPassword123!"
        ClipboardManager.copyToClipboard(testString)
        #expect(ClipboardManager.clipboardContent() == testString)
    }

    @Test func clipboardContentReturnsNilWhenEmpty() {
        UIPasteboard.general.string = nil
        #expect(ClipboardManager.clipboardContent() == nil)
    }

    @Test func clipboardOverwritesPreviousContent() {
        ClipboardManager.copyToClipboard("first")
        ClipboardManager.copyToClipboard("second")
        #expect(ClipboardManager.clipboardContent() == "second")
    }

    @Test func clipboardHandlesEmptyString() {
        ClipboardManager.copyToClipboard("")
        #expect(ClipboardManager.clipboardContent() == "")
    }
}
