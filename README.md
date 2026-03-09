# PopUp Translator

macOS 메뉴바 번역기 앱. `⌘⇧T` 단축키로 화면 우측 상단에 팝업을 띄워 **자동감지 → 영어 / 한국어** 동시 번역 결과를 보여줍니다.

## 기능

- 글로벌 단축키 `⌘⇧T`로 어디서든 즉시 팝업
- 입력 언어 자동 감지
- 영어 / 한국어 동시 번역 결과 표시
- 입력과 동일한 언어 결과는 흐리게 처리
- 번역 결과 클릭 한 번으로 클립보드 복사
- 300ms 디바운스로 자동 번역
- Escape 키로 팝업 닫기
- 메뉴바 상주 (Dock 아이콘 없음)

## 요구사항

- macOS 14.0 (Sonoma) 이상
- Xcode 16.0 이상 (빌드 시)

## 빌드 및 실행

### Xcode로 빌드 (권장)

```bash
# Xcode 프로젝트 생성 (xcodegen 필요)
brew install xcodegen
xcodegen generate

# Xcode에서 열기
open PopUpTranslator.xcodeproj
```

Xcode에서 `⌘R`로 빌드 및 실행합니다.

### Swift CLI로 빌드

```bash
swift build
# 실행 파일: .build/debug/PopUpTranslator
```

## 사용법

1. 앱 실행 시 메뉴바에 🌐 아이콘이 나타납니다
2. `⌘⇧T`를 누르면 화면 우측 상단에 번역 팝업이 나타납니다
3. 텍스트를 입력하면 자동으로 영어/한국어 번역 결과가 표시됩니다
4. 복사 버튼으로 결과를 클립보드에 복사할 수 있습니다
5. `Escape` 또는 팝업 바깥 클릭으로 닫습니다

## 프로젝트 구조

```
PopUpTranslator/
├── PopUpTranslatorApp.swift      # 앱 진입점, MenuBarExtra, AppDelegate
├── KeyboardShortcutNames.swift   # 글로벌 단축키 등록 (⌘⇧T)
├── FloatingPanel.swift           # NSPanel 서브클래스 (플로팅 팝업)
├── PanelManager.swift            # 패널 생성/위치/토글 관리
├── TranslatorView.swift          # 메인 UI
├── TranslatorViewModel.swift     # 번역 로직, 디바운스, 상태 관리
├── TranslationService.swift      # Google Translate API 호출
├── Info.plist                    # LSUIElement, ATS 설정
└── Assets.xcassets/              # 앱 아이콘, 색상
```

## 기술 스택

- **Swift 5.9+** / **SwiftUI** + AppKit
- **HotKey** (soffes) - 글로벌 키보드 단축키
- **Google Translate** 비공식 API - 무료, API 키 불필요
