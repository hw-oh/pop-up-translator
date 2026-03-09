import SwiftUI
import HotKey

@main
struct PopUpTranslatorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(systemName: "globe")
        }
    }
}

struct MenuBarView: View {
    @State private var shortcutDisplay = GlobalHotKeys.displayString

    var body: some View {
        Button("번역기 열기  \(shortcutDisplay)") {
            Task { @MainActor in
                PanelManager.shared.toggle()
            }
        }

        Divider()

        Button("단축키 변경...") {
            Task { @MainActor in
                ShortcutSettingsWindow.show()
            }
        }

        Button("앱 정보") {
            Task { @MainActor in
                AboutWindow.show()
            }
        }

        Divider()

        Button("종료") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: [.command])
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        GlobalHotKeys.register {
            Task { @MainActor in
                PanelManager.shared.toggle()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        GlobalHotKeys.unregister()
    }
}

// MARK: - About Window

enum AboutWindow {
    private static var window: NSWindow?

    @MainActor
    static func show() {
        if let w = window, w.isVisible {
            w.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = AboutView()
        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        w.title = "PopUp Translator"
        w.contentView = NSHostingView(rootView: view)
        w.center()
        w.isReleasedWhenClosed = false
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window = w
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.linearGradient(
                        colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 48)
                Image(systemName: "globe")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("PopUp Translator")
                .font(.system(size: 15, weight: .semibold, design: .rounded))

            Text("v1.0.0")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            Button {
                NSWorkspace.shared.open(URL(string: "https://github.com/hw-oh/pop-up-translator")!)
            } label: {
                HStack(spacing: 4) {
                    GitHubIcon()
                        .frame(width: 14, height: 14)
                    Text("github.com/hw-oh/pop-up-translator")
                        .font(.system(size: 11))
                }
                .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)

            Text("made by hw-oh")
                .font(.system(size: 10))
                .foregroundStyle(Color.primary.opacity(0.35))
        }
        .padding(20)
        .frame(width: 280, height: 200)
    }
}

// MARK: - Shortcut Settings Window

enum ShortcutSettingsWindow {
    private static var window: NSWindow?

    @MainActor
    static func show() {
        if let w = window, w.isVisible {
            w.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = ShortcutSettingsView()
        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 140),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        w.title = "단축키 설정"
        w.contentView = NSHostingView(rootView: view)
        w.center()
        w.isReleasedWhenClosed = false
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window = w
    }
}

struct ShortcutSettingsView: View {
    @State private var isRecording = false
    @State private var displayText = GlobalHotKeys.displayString

    var body: some View {
        VStack(spacing: 16) {
            Text("번역기 단축키")
                .font(.system(size: 13, weight: .semibold))

            HStack(spacing: 12) {
                Text(isRecording ? "키를 입력하세요..." : displayText)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(isRecording ? .orange : .primary)
                    .frame(width: 160, height: 32)
                    .background(Color.primary.opacity(isRecording ? 0.08 : 0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(isRecording ? Color.orange.opacity(0.5) : Color.primary.opacity(0.1), lineWidth: 1)
                    )

                Button(isRecording ? "취소" : "변경") {
                    if isRecording {
                        isRecording = false
                        NSEvent.removeMonitor(monitor as Any)
                        monitor = nil
                    } else {
                        startRecording()
                    }
                }
                .controlSize(.regular)
            }

            Text("Ctrl, Cmd, Option, Shift 중 2개 이상 + 문자키")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 320, height: 140)
    }

    @State private var monitor: Any?

    private func startRecording() {
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let mods = event.modifierFlags.intersection([.control, .option, .shift, .command])
            guard mods.rawValue != 0, let key = Key(carbonKeyCode: UInt32(event.keyCode)) else {
                return event
            }

            GlobalHotKeys.update(key: key, modifiers: mods)
            displayText = GlobalHotKeys.displayString
            isRecording = false

            if let m = monitor {
                NSEvent.removeMonitor(m)
            }
            monitor = nil
            return nil
        }
    }
}
