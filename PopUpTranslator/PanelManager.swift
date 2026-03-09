import AppKit
import SwiftUI
import Combine

@MainActor
final class PanelManager: ObservableObject {
    static let shared = PanelManager()

    private var panel: FloatingPanel?
    private var hostingView: NSHostingView<AnyView>?
    private var viewModel: TranslatorViewModel?
    private var cancellables = Set<AnyCancellable>()
    @Published var isVisible = false

    private let panelWidth: CGFloat = 340

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
        resizeAndPosition()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        isVisible = true
    }

    func hide() {
        panel?.orderOut(nil)
        isVisible = false
    }

    private func createPanel() {
        let frame = NSRect(x: 0, y: 0, width: panelWidth, height: 200)
        let panel = FloatingPanel(contentRect: frame)

        let vm = TranslatorViewModel()
        let view = TranslatorView(viewModel: vm)
            .frame(width: panelWidth)

        let hosting = NSHostingView(rootView: AnyView(view))
        hosting.translatesAutoresizingMaskIntoConstraints = false
        panel.contentView = hosting

        vm.objectWillChange
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.resizeAndPosition()
                }
            }
            .store(in: &cancellables)

        self.hostingView = hosting
        self.viewModel = vm
        self.panel = panel
    }

    private func resizeAndPosition() {
        guard let panel = panel, let hosting = hostingView, let screen = NSScreen.main else { return }

        let fittingSize = hosting.fittingSize
        let height = min(max(fittingSize.height, 180), 600)

        let visibleFrame = screen.visibleFrame
        let x = visibleFrame.maxX - panelWidth - 6
        let y = visibleFrame.maxY - height

        panel.setFrame(NSRect(x: x, y: y, width: panelWidth, height: height), display: true, animate: false)
    }
}
