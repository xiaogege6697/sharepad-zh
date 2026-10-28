import SwiftUI

struct TrialOverlayView: View {
    var onBuy: (() -> Void)?
    var onEnterLicense: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.section) {
            Image(systemName: "hourglass")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("免费试用已结束")
                .font(.title2.bold())
            Text("输入许可证即可恢复投屏，离线可用，无需账号。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            HStack(spacing: Theme.Spacing.section) {
                if let onBuy {
                    Button("购买许可证", action: onBuy)
                }
                Button("输入许可证", action: onEnterLicense)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(Theme.Spacing.overlayInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
