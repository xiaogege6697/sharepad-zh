import AppKit
import SwiftUI

// A MenuBarExtra (.window) popover dismisses the moment focus leaves it, so a
// `.sheet` presented from it can't hold keyboard focus — text fields can't be
// edited and the form vanishes. Licence entry therefore lives in a real, focusable
// window (same approach as the About panel), independent of the popover.
@MainActor
enum LicenseWindow {
    private static var window: NSWindow?

    static func present(model: AppModel) {
        let win = window ?? makeWindow()
        // A reused window must never reopen on a stale success screen or a
        // still-pending auto-close task left over from a prior visit.
        win.contentViewController = NSHostingController(
            rootView: LicenseEntryView(model: model, onClose: { win.close() })
        )
        win.center()
        window = win
        NSApp.activate(ignoringOtherApps: true)
        win.makeKeyAndOrderFront(nil)
    }

    private static func makeWindow() -> NSWindow {
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "输入 SharePad 许可证"
        win.isReleasedWhenClosed = false
        // The share window floats when "投屏窗口置顶" is on, so a normal-level
        // entry window would open behind it (and the trial-pause overlay) where the
        // user never sees it. Float the entry window so it sits above the feed.
        win.level = .floating
        return win
    }
}

struct LicenseEntryView: View {
    let model: AppModel
    let onClose: () -> Void
    @State private var email = ""
    @State private var key = ""
    @State private var failure: LicenseCheck?
    @State private var activated = false

    var body: some View {
        Group {
            if activated {
                activatedView
            } else {
                form
            }
        }
        .padding()
        .frame(width: 340)
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.row) {
            Text("一次购买，离线可用，无需注册或登录。")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("购买时使用的邮箱", text: $email)
            TextField("许可证密钥", text: $key)
            if let failureMessage {
                Text(failureMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            HStack {
                if License.recoverURL != nil {
                    Button("找回密钥") { model.openRecoverPage() }
                        .buttonStyle(.link)
                }
                Spacer()
                Button("取消") { onClose() }
                    .keyboardShortcut(.cancelAction)
                Button("激活") {
                    let result = model.enterLicense(email: email, key: key)
                    if result == .valid {
                        activated = true
                    } else {
                        failure = result
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(email.isEmpty || key.isEmpty)
            }
        }
        .onChange(of: email) { failure = nil }
        .onChange(of: key) { failure = nil }
    }

    private var failureMessage: String? {
        switch failure {
        case .malformedKey:
            "许可证不完整，请从购买邮件中复制完整密钥。"
        case .mismatch:
            "密钥与邮箱不匹配，请使用购买时的邮箱。"
        case .valid, .none:
            nil
        }
    }

    private var activatedView: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.row) {
            Label("许可证已激活", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.green)
            Text("感谢购买 SharePad，使用时限已解除。")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Spacer()
                Button("完成") { onClose() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(4))
            onClose()
        }
    }
}
