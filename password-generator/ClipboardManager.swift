//
//  ClipboardManager.swift
//  password-generator
//
//  Created by Stone Fuglaar on 7/28/26.
//

import UIKit

struct ClipboardManager {

    static func copyToClipboard(_ text: String) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                UIPasteboard.general.string = text
                continuation.resume()
            }
        }
    }

    static func clipboardContent() -> String? {
        UIPasteboard.general.string
    }
}
