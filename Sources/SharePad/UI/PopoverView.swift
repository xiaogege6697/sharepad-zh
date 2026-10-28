import AppKit
import SwiftUI

struct PopoverView: View {
    @Environment(AppModel.self) private var model
    let updater: SoftwareUpdating

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.row) {
            header

            shareLostBanner

            thumbnail

            statusText
                .foregroundStyle(.secondary)

            if let hint = statusHint {
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            devicePicker

            stateAction

            Button(model.isWindowVisible ? "隐藏投屏窗口" : "显示投屏窗口") {
                model.toggleWindow()
            }
            .disabled(!model.isConnected)

            Group {
                Button("窗口最大化／还原") { model.maximizeWindow() }
                Button("进入／退出全屏") { model.toggleFullScreen() }
                Button("恢复居中默认大小") { model.resetWindow() }
            }
            .disabled(!model.isWindowVisible)

            if model.isWindowHotkeyActive {
                Text("全局显示／隐藏：\(GlobalHotkey.WindowToggle.display)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Toggle("连接后自动显示", isOn: Binding(
                get: { model.autoShowOnConnect },
                set: { model.setAutoShow($0) }
            ))
            Toggle("投屏窗口置顶", isOn: Binding(
                get: { model.keepOnTop },
                set: { model.setKeepOnTop($0) }
            ))
            Toggle("开机启动", isOn: Binding(
                get: { model.launchAtLogin },
                set: { model.setLaunchAtLogin($0) }
            ))
            if model.launchAtLoginFailed {
                Text("无法修改开机启动，请打开“系统设置 → 登录项”。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Toggle("发送匿名崩溃报告", isOn: Binding(
                get: { model.diagnosticsEnabled },
                set: { model.setDiagnosticsEnabled($0) }
            ))
            Text("默认关闭。仅发送崩溃与错误诊断，不含投屏内容或许可证。")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            licenseSection

            #if LOCAL_BUILD
            Text("中文自用版 · 无使用时限")
                .font(.caption)
                .foregroundStyle(.secondary)
            #else
            Button("检查更新…") { updater.checkForUpdates() }
            #endif

            Button("退出 SharePad") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding()
        .frame(width: 260)
        .onAppear { model.popoverDidAppear() }
        .onDisappear { model.popoverDidDisappear() }
    }

    @ViewBuilder private var licenseSection: some View {
        switch model.entitlement {
        case .licensed:
            EmptyView()
        case let .trial(daysLeft):
            licenseRow(status: "免费试用剩余 \(daysLeft) 天")
        case .trialExpired:
            trialExpiredRow
        }
    }

    @ViewBuilder private var trialExpiredRow: some View {
        if model.isTrialOverlayShown {
            licenseRow(status: "投屏已暂停，请输入许可证恢复")
        } else if let endsAt = model.sessionEndsAt {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                licenseRow(status: "试用已结束，距离暂停还有 "
                    + SessionCountdown.remainingText(until: endsAt, now: context.date))
            }
        } else {
            licenseRow(
                status: "试用已结束，投屏将在 \(model.sessionLimitMinutes) 分钟后暂停"
            )
        }
    }

    private func licenseRow(status: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.row) {
            Text(status)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                if License.buyURL != nil {
                    Button("购买许可证") { model.openBuyPage() }
                }
                Button("输入许可证…") { LicenseWindow.present(model: model) }
            }
            Divider()
        }
    }

    private var header: some View {
        HStack {
            Text("SharePad")
                .font(.headline)
            Spacer()
            Button {
                AboutPanel.present()
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .help("关于 SharePad")
        }
    }

    @ViewBuilder private var shareLostBanner: some View {
        if model.shareLostSignal {
            HStack(spacing: Theme.Spacing.row) {
                Image(systemName: "cable.connector.slash")
                    .foregroundStyle(.secondary)
                Text("iPad 已断开连接")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    model.dismissShareLost()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
                .help("关闭提示")
            }
            .padding(Theme.Spacing.row)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        }
    }

    @ViewBuilder private var thumbnail: some View {
        if model.isLive {
            PreviewView(layer: model.thumbnailLayer)
                .frame(maxWidth: .infinity)
                .frame(height: 146)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.thumbnail))
        }
    }

    @ViewBuilder private var devicePicker: some View {
        if model.devices.count > 1 {
            Picker("投屏设备", selection: Binding(
                get: { model.currentDeviceID ?? "" },
                set: { model.selectDevice(id: $0) }
            )) {
                ForEach(model.devices) { device in
                    Text(device.name).tag(device.id)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
        }
    }

    @ViewBuilder private var stateAction: some View {
        switch model.state {
        case .permissionDenied:
            Button("打开系统设置") { model.openCameraSettings() }
        case .failed:
            Button("重试") { model.retry() }
        default:
            EmptyView()
        }
    }

    private var statusText: Text {
        switch model.state {
        case .checkingPermission: Text("正在请求摄像头权限…")
        case .permissionDenied: Text("尚未允许摄像头权限。")
        case .permissionRestricted: Text("摄像头权限被设备管理策略限制。")
        case .noDevice: Text("尚未连接 iPad")
        case .starting: Text("正在连接…")
        case .live: Text(model.currentDeviceName ?? "iPad")
        case .failed: Text("无法启动 iPad 投屏。")
        }
    }

    // A connected-but-locked or not-yet-trusted iPad shows up to discovery but never
    // starts a session, so it sits in .starting looking stuck (the hint also flashes
    // briefly on a healthy connect). The app can't tell "locked" from "still trusting".
    private var statusHint: String? {
        switch model.state {
        case .noDevice: "用 USB 数据线连接 iPad，即可开始投屏。"
        case .starting: "请解锁 iPad，如有提示，请点“信任此电脑”。"
        case .failed: "请确认 iPad 已解锁并连接，再点“重试”。"
        default: nil
        }
    }
}
