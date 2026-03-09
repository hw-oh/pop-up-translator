import AppKit
import SwiftUI

@MainActor
final class PanelManager: ObservableObject {
    static let shared = PanelManager()

    private var panel: FloatingPanel?
    private var viewModel: TranslatorViewModel?
    @Published var isVisible = false

    private let panelWidth: CGFloat = 340
    private let panelHeight: CGFloat = 300

    private init() {}

    func toggle() {
        if let panel = panel, panel.isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        if panel == nil {
            createPanel()
        }

        guard let panel = panel else { return }

        viewModel?.clear()
        positionPanel(panel)
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        isVisible = true
    }

    func hide() {
        panel?.orderOut(nil)
        isVisible = false
    }

    private func createPanel() {
        let frame = NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight)
        let panel = FloatingPanel(contentRect: frame)

        let vm = TranslatorViewModel()
        let view = TranslatorView(viewModel: vm)
            .frame(width: panelWidth, height: panelHeight)

        panel.contentView = NSHostingView(rootView: view)
        self.viewModel = vm
        self.panel = panel
    }

    private func positionPanel(_ panel: FloatingPanel) {
        guard let screen = NSScreen.main else { return }

        let visibleFrame = screen.visibleFrame
        let x = visibleFrame.maxX - panelWidth - 12
        let y = visibleFrame.maxY - panelHeight - 12

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
