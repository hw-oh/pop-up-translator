import Foundation

struct Language: Identifiable, Hashable, Codable {
    let code: String
    let name: String

    var id: String { code }

    static let all: [Language] = [
        Language(code: "ko", name: "한국어"),
        Language(code: "en", name: "English"),
        Language(code: "ja", name: "日本語"),
        Language(code: "zh-CN", name: "中文(简体)"),
        Language(code: "zh-TW", name: "中文(繁體)"),
        Language(code: "es", name: "Español"),
        Language(code: "fr", name: "Français"),
        Language(code: "de", name: "Deutsch"),
        Language(code: "pt", name: "Português"),
        Language(code: "ru", name: "Русский"),
        Language(code: "vi", name: "Tiếng Việt"),
        Language(code: "th", name: "ไทย"),
        Language(code: "id", name: "Indonesia"),
        Language(code: "it", name: "Italiano"),
        Language(code: "nl", name: "Nederlands"),
        Language(code: "ar", name: "العربية"),
        Language(code: "hi", name: "हिन्दी"),
    ]

    static func find(code: String) -> Language? {
        all.first { $0.code == code }
    }
}
