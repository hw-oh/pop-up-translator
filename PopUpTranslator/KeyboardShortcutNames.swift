import HotKey
import Carbon
import AppKit

enum GlobalHotKeys {
    static var toggleTranslator: HotKey?
    private static var handler: (() -> Void)?

    static var currentKey: Key {
        get {
            guard let raw = UserDefaults.standard.value(forKey: "hotkeyKey") as? UInt32 else { return .t }
            return Key(carbonKeyCode: raw) ?? .t
        }
        set { UserDefaults.standard.set(newValue.carbonKeyCode, forKey: "hotkeyKey") }
    }

    static var currentModifiers: NSEvent.ModifierFlags {
        get {
            guard let raw = UserDefaults.standard.value(forKey: "hotkeyMod") as? UInt else {
                return [.control, .command]
            }
            return NSEvent.ModifierFlags(rawValue: raw)
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "hotkeyMod") }
    }

    static var displayString: String {
        var parts: [String] = []
        let m = currentModifiers
        if m.contains(.control) { parts.append("⌃") }
        if m.contains(.option) { parts.append("⌥") }
        if m.contains(.shift) { parts.append("⇧") }
        if m.contains(.command) { parts.append("⌘") }
        parts.append(currentKey.description.uppercased())
        return parts.joined()
    }

    static func register(handler: @escaping () -> Void) {
        self.handler = handler
        rebind()
    }

    static func rebind() {
        toggleTranslator = nil
        guard let handler = handler else { return }
        let hotKey = HotKey(key: currentKey, modifiers: currentModifiers)
        hotKey.keyDownHandler = handler
        toggleTranslator = hotKey
    }

    static func update(key: Key, modifiers: NSEvent.ModifierFlags) {
        currentKey = key
        currentModifiers = modifiers
        rebind()
    }

    static func unregister() {
        toggleTranslator = nil
        handler = nil
    }
}

extension Key {
    var description: String {
        switch self {
        case .a: return "A"
        case .b: return "B"
        case .c: return "C"
        case .d: return "D"
        case .e: return "E"
        case .f: return "F"
        case .g: return "G"
        case .h: return "H"
        case .i: return "I"
        case .j: return "J"
        case .k: return "K"
        case .l: return "L"
        case .m: return "M"
        case .n: return "N"
        case .o: return "O"
        case .p: return "P"
        case .q: return "Q"
        case .r: return "R"
        case .s: return "S"
        case .t: return "T"
        case .u: return "U"
        case .v: return "V"
        case .w: return "W"
        case .x: return "X"
        case .y: return "Y"
        case .z: return "Z"
        case .zero: return "0"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .space: return "Space"
        default: return "?"
        }
    }
}
