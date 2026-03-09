import SwiftUI

struct TranslatorView: View {
    @ObservedObject var viewModel: TranslatorViewModel
    @FocusState private var isInputFocused: Bool
    @State private var copied = false

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            content
        }
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
        .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isInputFocused = true
            }
        }
        .onExitCommand {
            PanelManager.shared.hide()
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.linearGradient(
                        colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 24, height: 24)
                Image(systemName: "globe")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("Translator")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary.opacity(0.8))

            Spacer()

            if viewModel.isTranslating {
                ProgressView()
                    .controlSize(.small)
                    .scaleEffect(0.65)
                    .transition(.opacity)
            }

            Button {
                viewModel.clear()
                isInputFocused = true
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("초기화")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 12) {
            inputSection

            if let error = viewModel.errorMessage {
                errorBanner(error)
            }

            if !viewModel.translatedText.isEmpty || !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                resultSection
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
        .padding(.top, 4)
    }

    // MARK: - Input

    private var inputSection: some View {
        TextField("번역할 텍스트 입력...", text: $viewModel.inputText, axis: .vertical)
            .font(.system(size: 13))
            .lineLimit(1...5)
            .textFieldStyle(.plain)
            .focused($isInputFocused)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .onChange(of: viewModel.inputText) { _, _ in
                viewModel.onInputChanged()
            }
            .background(Color.primary.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(
                        isInputFocused
                            ? Color.accentColor.opacity(0.4)
                            : Color.primary.opacity(0.08),
                        lineWidth: 1
                    )
            )
    }

    // MARK: - Result

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                langBadge

                Spacer()

                if !viewModel.translatedText.isEmpty {
                    copyButton
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 8)

            Rectangle()
                .fill(Color.primary.opacity(0.06))
                .frame(height: 0.5)
                .padding(.horizontal, 8)

            Text(viewModel.translatedText.isEmpty ? "..." : viewModel.translatedText)
                .font(.system(size: 14))
                .lineSpacing(4)
                .foregroundStyle(viewModel.translatedText.isEmpty ? .tertiary : .primary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.07), lineWidth: 0.5)
        )
        .animation(.easeInOut(duration: 0.15), value: viewModel.translatedText)
    }

    private var langBadge: some View {
        HStack(spacing: 4) {
            if !viewModel.detectedLanguage.isEmpty {
                Text(viewModel.detectedLanguageDisplay)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                Image(systemName: "arrow.right")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.tertiary)
            }

            Text(viewModel.targetLabel)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(.linearGradient(
                            colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                )
        }
    }

    private var copyButton: some View {
        Button {
            viewModel.copyToClipboard(viewModel.translatedText)
            withAnimation(.spring(duration: 0.25)) { copied = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.2)) { copied = false }
            }
        } label: {
            HStack(spacing: 3) {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 10, weight: .medium))
                if copied {
                    Text("복사됨")
                        .font(.system(size: 10, weight: .medium))
                }
            }
            .foregroundStyle(copied ? .green : .secondary)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(copied ? Color.green.opacity(0.1) : Color.primary.opacity(0.05))
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Error

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 11))
                .foregroundStyle(.orange)
            Text(message)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(10)
        .background(Color.orange.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
