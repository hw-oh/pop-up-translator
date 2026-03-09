import AppKit
import Combine

@MainActor
final class TranslatorViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var englishResult = ""
    @Published var koreanResult = ""
    @Published var detectedLanguage = ""
    @Published var isTranslating = false
    @Published var errorMessage: String?

    private var debounceTask: Task<Void, Never>?
    private let service = TranslationService.shared

    var detectedLanguageDisplay: String {
        switch detectedLanguage {
        case "ko": return "한국어"
        case "en": return "English"
        case "ja": return "日本語"
        case "zh-CN", "zh-TW": return "中文"
        case "fr": return "Français"
        case "de": return "Deutsch"
        case "es": return "Español"
        case "": return ""
        default: return detectedLanguage.uppercased()
        }
    }

    var translatedText: String {
        if detectedLanguage == "ko" {
            return englishResult
        } else {
            return koreanResult
        }
    }

    var targetLabel: String {
        if detectedLanguage == "ko" {
            return "English"
        } else {
            return "한국어"
        }
    }

    func onInputChanged() {
        debounceTask?.cancel()

        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            englishResult = ""
            koreanResult = ""
            detectedLanguage = ""
            errorMessage = nil
            return
        }

        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await performTranslation(text: text)
        }
    }

    private func performTranslation(text: String) async {
        isTranslating = true
        errorMessage = nil

        let result = await service.translateBoth(text: text)

        guard !Task.isCancelled else { return }

        if let error = result.error {
            errorMessage = error.localizedDescription
        } else {
            englishResult = result.english?.translatedText ?? ""
            koreanResult = result.korean?.translatedText ?? ""
            detectedLanguage = result.english?.detectedLanguage ?? result.korean?.detectedLanguage ?? ""
        }

        isTranslating = false
    }

    func clear() {
        inputText = ""
        englishResult = ""
        koreanResult = ""
        detectedLanguage = ""
        errorMessage = nil
    }

    func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
