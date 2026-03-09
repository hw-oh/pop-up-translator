# PopUp Translator

> **[한국어 README](README_ko.md)**

A macOS menu bar translator app. Press `⌃⌘T` to instantly open a popup in the top-right corner that auto-detects the input language and translates to the opposite language.

## Features

- Global shortcut `⌃⌘T` to open the popup from anywhere (customizable)
- Auto-detects input language → shows only the opposite translation
- **17 languages** supported — Korean, English, 日本語, 中文, Español, Français, Deutsch, and more
- Freely choose any language pair (swap with ↔ button)
- Language pair and shortcut persisted across app restarts
- Popup auto-resizes to fit content
- One-click copy to clipboard
- 300ms debounced auto-translation
- Close with Escape or click outside
- Lives in the menu bar (no Dock icon)
- About / shortcut settings menu

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 16.0 or later (for building)

## Build & Run

### With Xcode (recommended)

```bash
brew install xcodegen
xcodegen generate
open PopUpTranslator.xcodeproj
```

Build and run with `⌘R` in Xcode.

### With Swift CLI

```bash
swift build -c release

# Create .app bundle
mkdir -p PopUpTranslator.app/Contents/{MacOS,Resources}
cp .build/release/PopUpTranslator PopUpTranslator.app/Contents/MacOS/
cp PopUpTranslator/Info.plist PopUpTranslator.app/Contents/Info.plist

# Launch
open PopUpTranslator.app
```

## Usage

1. On launch, a 🌐 icon appears in the menu bar
2. Press `⌃⌘T` to open the translator popup at the top-right corner
3. Select your language pair from the language bar
4. Type text — it auto-detects the language and translates to the other one
5. Click the copy button to copy the result to clipboard
6. Press `Escape` or click outside to close
7. Click the menu bar icon → "단축키 변경..." to customize the shortcut

## Project Structure

```
PopUpTranslator/
├── PopUpTranslatorApp.swift      # App entry, MenuBarExtra, About/Settings windows
├── KeyboardShortcutNames.swift   # Global hotkey registration/persistence
├── FloatingPanel.swift           # NSPanel subclass (floating popup)
├── PanelManager.swift            # Panel creation/positioning/dynamic resizing
├── TranslatorView.swift          # Main UI (language bar + input + result)
├── TranslatorViewModel.swift     # Translation logic, debounce, language pair management
├── TranslationService.swift      # Google Translate API calls
├── Language.swift                # Supported languages model (17 languages)
├── SocialIcons.swift             # GitHub icon
├── Info.plist                    # LSUIElement, ATS config
└── Assets.xcassets/              # App icon
```

## Tech Stack

- **Swift 5.9+** / **SwiftUI** + AppKit
- **HotKey** (soffes) — Global keyboard shortcuts
- **Google Translate** unofficial API — Free, no API key required
