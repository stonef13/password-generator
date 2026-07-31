//
//  ClipboardManager.swift
//  password-generator
//
//  Created by Stone Fuglaar on 7/28/26.
//

import UIKit

struct ClipboardManager {

    static func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }

    static func clipboardContent() -> String? {
        UIPasteboard.general.string
    }
}
