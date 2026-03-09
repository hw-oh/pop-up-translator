# PopUp Translator

> **[English README](README.md)**

macOS 메뉴바 번역기 앱. `⌃⌘T` 단축키로 화면 우측 상단에 팝업을 띄워, 입력 언어를 자동 감지하고 반대 언어로 번역합니다.

## 기능

- 글로벌 단축키 `⌃⌘T`로 어디서든 즉시 팝업 (단축키 변경 가능)
- 입력 언어 자동 감지 → 반대 언어 번역 결과만 표시
- **17개 언어** 지원 — 한국어, English, 日本語, 中文, Español, Français, Deutsch 등
- 언어 쌍 자유롭게 선택 가능 (↔ 버튼으로 교체)
- 선택한 언어 쌍 / 단축키 자동 저장 (앱 재시작 시 유지)
- 콘텐츠에 맞게 팝업 크기 자동 조절
- 번역 결과 복사 버튼
- 300ms 디바운스 자동 번역
- Escape 키 또는 바깥 클릭으로 팝업 닫기
- 메뉴바 상주 (Dock 아이콘 없음)
- 앱 정보 / 단축키 변경 메뉴

## 요구사항

- macOS 14.0 (Sonoma) 이상
- Xcode 16.0 이상 (빌드 시)

## 빌드 및 실행

### Xcode로 빌드 (권장)

```bash
brew install xcodegen
xcodegen generate
open PopUpTranslator.xcodeproj
```

Xcode에서 `⌘R`로 빌드 및 실행합니다.

### Swift CLI로 빌드

```bash
swift build -c release

# .app 번들 생성
mkdir -p PopUpTranslator.app/Contents/{MacOS,Resources}
cp .build/release/PopUpTranslator PopUpTranslator.app/Contents/MacOS/
cp PopUpTranslator/Info.plist PopUpTranslator.app/Contents/Info.plist

# 실행
open PopUpTranslator.app
```

## 사용법

1. 앱 실행 시 메뉴바에 🌐 아이콘이 나타납니다
2. `⌃⌘T`를 누르면 화면 우측 상단에 번역 팝업이 나타납니다
3. 상단 언어 바에서 원하는 언어 쌍을 선택합니다
4. 텍스트를 입력하면 자동 감지된 언어의 반대 언어로 번역됩니다
5. 복사 버튼으로 결과를 클립보드에 복사할 수 있습니다
6. `Escape` 또는 팝업 바깥 클릭으로 닫습니다
7. 메뉴바 아이콘 클릭 → "단축키 변경..."으로 단축키 커스터마이즈 가능

## 프로젝트 구조

```
PopUpTranslator/
├── PopUpTranslatorApp.swift      # 앱 진입점, MenuBarExtra, 앱 정보/단축키 설정 윈도우
├── KeyboardShortcutNames.swift   # 글로벌 단축키 등록/변경/저장
├── FloatingPanel.swift           # NSPanel 서브클래스 (플로팅 팝업)
├── PanelManager.swift            # 패널 생성/위치/동적 크기 조절
├── TranslatorView.swift          # 메인 UI (언어 선택 바 + 입력 + 결과)
├── TranslatorViewModel.swift     # 번역 로직, 디바운스, 언어 쌍 관리
├── TranslationService.swift      # Google Translate API 호출
├── Language.swift                # 지원 언어 모델 (17개)
├── SocialIcons.swift             # GitHub 아이콘
├── Info.plist                    # LSUIElement, ATS 설정
└── Assets.xcassets/              # 앱 아이콘
```

## 기술 스택

- **Swift 5.9+** / **SwiftUI** + AppKit
- **HotKey** (soffes) — 글로벌 키보드 단축키
- **Google Translate** 비공식 API — 무료, API 키 불필요
