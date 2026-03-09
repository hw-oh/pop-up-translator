import HotKey
import Carbon

enum GlobalHotKeys {
    static var toggleTranslator: HotKey?

    static func register(handler: @escaping () -> Void) {
        let hotKey = HotKey(key: .t, modifiers: [.command, .shift])
        hotKey.keyDownHandler = handler
        toggleTranslator = hotKey
    }

    static func unregister() {
        toggleTranslator = nil
    }
}
