import AppKit

@MainActor
enum AboutPanel {
    private static let repo = "https://github.com/jonyardley/SharePad"
    private static let issues = "https://github.com/jonyardley/SharePad/issues"
    private static let licence = "https://github.com/jonyardley/SharePad/blob/main/LICENSE"
    private static let tagline =
        "将 USB 连接的 iPad 变成可在网课或视频会议中共享的投屏窗口。"
    private static let licenceNotice =
        "本软件以 GPLv3 协议开源，不提供担保。本机中文自用构建。"

    static func present() {
        // As an LSUIElement agent app the panel can open behind the frontmost
        // window; activate so it comes forward.
        NSApp.activate()
        NSApp.orderFrontStandardAboutPanel(options: [.credits: credits])
    }

    private static var credits: NSAttributedString {
        let body = NSMutableAttributedString(
            string: tagline + "\n\n" + licenceNotice + "\n\n",
            attributes: [
                .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
                .foregroundColor: NSColor.secondaryLabelColor,
            ]
        )
        body.append(link("查看源码", url: repo))
        body.append(separator)
        body.append(link("开源协议", url: licence))
        body.append(separator)
        body.append(link("反馈问题", url: issues))
        // Buy link uses the same decoupled buy path as the in-app gate
        // (buy.sharepad.co -> 302 -> processor), so it's the single source of truth.
        if let buy = License.buyURL?.absoluteString {
            body.append(separator)
            body.append(link("购买许可证", url: buy))
        }

        let centered = NSMutableParagraphStyle()
        centered.alignment = .center
        body.addAttribute(
            .paragraphStyle,
            value: centered,
            range: NSRange(location: 0, length: body.length)
        )
        return body
    }

    private static func link(_ text: String, url: String) -> NSAttributedString {
        NSAttributedString(
            string: text,
            attributes: [
                .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
                .link: url,
            ]
        )
    }

    private static var separator: NSAttributedString {
        NSAttributedString(
            string: "  ·  ",
            attributes: [
                .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
                .foregroundColor: NSColor.secondaryLabelColor,
            ]
        )
    }
}
