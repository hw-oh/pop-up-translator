import Foundation

struct TranslationResult {
    let translatedText: String
    let detectedLanguage: String
    let targetLanguage: String
}

final class TranslationService {
    static let shared = TranslationService()
    private init() {}

    private let baseURL = "https://translate.googleapis.com/translate_a/single"

    func translate(text: String, to targetLanguage: String) async throws -> TranslationResult {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return TranslationResult(translatedText: "", detectedLanguage: "", targetLanguage: targetLanguage)
        }

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "client", value: "gtx"),
            URLQueryItem(name: "sl", value: "auto"),
            URLQueryItem(name: "tl", value: targetLanguage),
            URLQueryItem(name: "dt", value: "t"),
            URLQueryItem(name: "q", value: text)
        ]

        guard let url = components.url else {
            throw TranslationError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TranslationError.serverError
        }

        return try parseResponse(data: data, targetLanguage: targetLanguage)
    }

    func translateBoth(text: String) async -> (english: TranslationResult?, korean: TranslationResult?, error: Error?) {
        do {
            async let englishResult = translate(text: text, to: "en")
            async let koreanResult = translate(text: text, to: "ko")

            let en = try await englishResult
            let ko = try await koreanResult
            return (en, ko, nil)
        } catch {
            return (nil, nil, error)
        }
    }

    // Google Translate returns a nested JSON array:
    // [[["translated text","original text",null,null,10]],null,"detected_lang"]
    private func parseResponse(data: Data, targetLanguage: String) throws -> TranslationResult {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [Any] else {
            throw TranslationError.parsingFailed
        }

        var translatedText = ""
        if let sentences = json[0] as? [[Any]] {
            for sentence in sentences {
                if let part = sentence[0] as? String {
                    translatedText += part
                }
            }
        }

        var detectedLanguage = "unknown"
        if json.count > 2, let lang = json[2] as? String {
            detectedLanguage = lang
        }

        return TranslationResult(
            translatedText: translatedText,
            detectedLanguage: detectedLanguage,
            targetLanguage: targetLanguage
        )
    }
}

enum TranslationError: LocalizedError {
    case invalidURL
    case serverError
    case parsingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .serverError: return "Server error"
        case .parsingFailed: return "Failed to parse response"
        }
    }
}
