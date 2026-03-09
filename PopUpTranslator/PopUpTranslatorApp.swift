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
    var body: some View {
        Button("번역기 열기  ⌘⇧T") {
            Task { @MainActor in
                PanelManager.shared.toggle()
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
