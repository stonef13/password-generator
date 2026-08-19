# PasswordGen

A lightweight iOS password generator (SwiftUI): generate secure, customizable passwords with one tap, copy, and go. No backend, no account, nothing stored outside the device.

## Features

- Secure password generation (default: 12 characters, all four character classes)
- Length control: slider from 4 to 32 characters
- Character type toggles: Uppercase, Lowercase, Numbers, Symbols (at least one always enabled)
- Exclude ambiguous characters (0/O, 1/l/I, etc.)
- Password strength indicator (Weak / Medium / Strong)
- One-tap copy with "Copied!" confirmation
- History of the last 10 generated passwords with timestamps, persisted in `UserDefaults`
- Favorite passwords for quick access (star icon on the generator screen and history rows)

## Requirements

- Xcode 16.4+
- iOS 18.0+
- macOS 15 (for CI)

## Build & Test

```sh
# Build
xcodebuild build \
  -project password-generator.xcodeproj \
  -scheme password-generator \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Unit + UI tests
xcodebuild test \
  -project password-generator.xcodeproj \
  -scheme password-generator \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Project Structure

- `password-generator/` — app sources: generation logic, history store, clipboard, SwiftUI views
- `password-generatorTests/` — unit tests (Swift Testing framework)
- `password-generatorUITests/` — UI tests (XCTest)
- `.github/workflows/` — CI: build + unit + UI tests on macOS 15 with Xcode 16.4

## Behavior Notes

- Auto-regeneration on setting changes updates the displayed password only.
- History records the initial password on launch and each explicit **Generate** tap.
- History is capped at 10 entries; the oldest entry is evicted when the cap is exceeded.
