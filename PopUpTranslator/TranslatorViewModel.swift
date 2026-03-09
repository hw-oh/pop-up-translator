import AppKit
import Combine

@MainActor
final class TranslatorViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var resultA = ""
    @Published var resultB = ""
    @Published var detectedLanguage = ""
    @Published var isTranslating = false
    @Published var errorMessage: String?

    @Published var langA: Language {
        didSet { UserDefaults.standard.set(langA.code, forKey: "langA"); retranslate() }
    }
    @Published var langB: Language {
        didSet { UserDefaults.standard.set(langB.code, forKey: "langB"); retranslate() }
    }

    private var debounceTask: Task<Void, Never>?
    private let service = TranslationService.shared

    init() {
        let codeA = UserDefaults.standard.string(forKey: "langA") ?? "en"
        let codeB = UserDefaults.standard.string(forKey: "langB") ?? "ko"
        self.langA = Language.find(code: codeA) ?? Language.all[1]
        self.langB = Language.find(code: codeB) ?? Language.all[0]
    }

    var detectedLanguageDisplay: String {
        Language.find(code: detectedLanguage)?.name ?? (detectedLanguage.isEmpty ? "" : detectedLanguage.uppercased())
    }

    var translatedText: String {
        if detectedLanguage == langA.code {
            return resultB
        } else {
            return resultA
        }
    }

    var targetLabel: String {
        if detectedLanguage == langA.code {
            return langB.name
        } else {
            return langA.name
        }
    }

    func onInputChanged() {
        debounceTask?.cancel()

        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            resultA = ""
            resultB = ""
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

    private func retranslate() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        debounceTask?.cancel()
        debounceTask = Task {
            await performTranslation(text: text)
        }
    }

    private func performTranslation(text: String) async {
        isTranslating = true
        errorMessage = nil

        do {
            async let rA = service.translate(text: text, to: langA.code)
            async let rB = service.translate(text: text, to: langB.code)

            let a = try await rA
            let b = try await rB

            guard !Task.isCancelled else { return }

            resultA = a.translatedText
            resultB = b.translatedText
            detectedLanguage = a.detectedLanguage
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }

        isTranslating = false
    }

    func swapLanguages() {
        let tmp = langA
        langA = langB
        langB = tmp
    }

    func clear() {
        inputText = ""
        resultA = ""
        resultB = ""
        detectedLanguage = ""
        errorMessage = nil
    }

    func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
