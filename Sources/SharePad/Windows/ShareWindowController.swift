import AppKit
import AVFoundation
import SwiftUI

@MainActor
final class ShareWindowController: NSObject, ShareWindowControlling, NSWindowDelegate {
    private var window: NSWindow?
    private var onClose: () -> Void = {}
    private var hasShown = false
    private var lastVideoSize = fallbackContentSize
    private let previewLayer: AVCaptureVideoPreviewLayer
    private let preferences: Preferences
    private var keepOnTop = false
    private var isObserving = false
    private let overlayModel = ShareOverlayModel()

    /// The frame as we last set it ourselves. The move/resize observers persist only
    /// when the live frame differs from this, so a programmatic restore/resize never
    /// saves its own (possibly clamped) value back over the user's chosen frame.
    private var appliedFrame: CGRect?

    private static let defaultLongSide: CGFloat = 900

    init(previewLayer: AVCaptureVideoPreviewLayer, preferences: Preferences) {
        self.previewLayer = previewLayer
        self.preferences = preferences
        super.init()
    }

    func setKeepOnTop(_ enabled: Bool) {
        keepOnTop = enabled
        window?.level = enabled ? .floating : .normal
    }

    /// Bring the window (and app) to the front. Without activation an accessory app's
    /// window orders in *behind* the active app, so the user never sees it.
    func show(size: CGSize) {
        let window = window ?? makeWindow()
        self.window = window
        startObserving()
        lastVideoSize = size
        if !hasShown {
            resetWindow()
            hasShown = true
        } else if !window.styleMask.contains(.fullScreen) {
            apply(size: size, to: window)
        }
        if window.isMiniaturized { window.deminiaturize(nil) }
        appliedFrame = window.frame
        window.makeKeyAndOrderFront(nil)
        NSApp.activate()
    }

    /// Driven by iPad rotation, not the user — so adapt the live window (keeping its
    /// centre) but don't persist. Overwriting the saved origin here would discard the
    /// user's chosen placement on every rotation; only their own move/resize persists.
    /// `appliedFrame` is refreshed so the move observer doesn't treat this as a user move.
    func updateSize(_ size: CGSize) {
        guard let window else { return }
        lastVideoSize = size
        window.contentAspectRatio = size
        guard !window.styleMask.contains(.fullScreen) else { return }
        let oldFrame = window.frame
        apply(size: size, to: window)
        window.setFrameOrigin(centeredResizeOrigin(
            oldFrame: oldFrame,
            newSize: window.frame.size,
            onScreens: screenFrames()
        ))
        appliedFrame = window.frame
    }

    func hide() {
        window?.orderOut(nil)
    }

    func setTrialOverlay(_ visible: Bool) {
        overlayModel.trialOverlayVisible = visible
    }

    func setTrialCountdown(endsAt: Date?) {
        overlayModel.sessionEndsAt = endsAt
    }

    func setTrialActions(onBuy: (() -> Void)?, onEnterLicense: @escaping () -> Void) {
        overlayModel.onBuy = onBuy
        overlayModel.onEnterLicense = onEnterLicense
    }

    private func apply(size videoSize: CGSize, to window: NSWindow) {
        window.level = keepOnTop ? .floating : .normal
        window.contentAspectRatio = videoSize
        let longSide = preferences.windowLongSide ?? Self.defaultLongSide
        let screen = window.screen ?? NSScreen.main
        let available = screen.map { window.contentRect(forFrameRect: $0.visibleFrame.insetBy(dx: 24, dy: 24)).size }
            ?? CGSize(width: 1200, height: 800)
        window.setContentSize(nativeContentSize(video: videoSize, available: available, longSide: longSide))
    }

    func setCloseAction(_ action: @escaping () -> Void) { onClose = action }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        onClose()
        return false
    }

    func maximizeWindow() {
        guard let window, !window.styleMask.contains(.fullScreen) else { return }
        window.zoom(nil)
    }

    func toggleFullScreen() { window?.toggleFullScreen(nil) }

    func resetWindow() {
        guard let window, !window.styleMask.contains(.fullScreen),
              let screen = window.screen ?? NSScreen.main else { return }
        let available = window.contentRect(forFrameRect: screen.visibleFrame.insetBy(dx: 24, dy: 24)).size
        window.contentAspectRatio = lastVideoSize
        window.setContentSize(nativeContentSize(video: lastVideoSize, available: available, longSide: Self.defaultLongSide))
        let visible = screen.visibleFrame
        window.setFrameOrigin(CGPoint(x: visible.midX - window.frame.width / 2,
                                      y: visible.midY - window.frame.height / 2))
        appliedFrame = window.frame
        persistFrame()
    }

    func windowWillUseStandardFrame(_ window: NSWindow, defaultFrame: NSRect) -> NSRect {
        let available = window.contentRect(forFrameRect: defaultFrame).size
        let size = nativeContentSize(video: lastVideoSize, available: available, longSide: .greatestFiniteMagnitude)
        var frame = window.frameRect(forContentRect: CGRect(origin: .zero, size: size))
        frame.origin = CGPoint(x: defaultFrame.midX - frame.width / 2, y: defaultFrame.midY - frame.height / 2)
        return frame
    }

    func windowWillEnterFullScreen(_ notification: Notification) { window?.level = .normal }
    func windowDidExitFullScreen(_ notification: Notification) {
        window?.level = keepOnTop ? .floating : .normal
        if let window { apply(size: lastVideoSize, to: window) }
    }

    private func persistFrame() {
        guard let window else { return }
        preferences.windowOrigin = window.frame.origin
        let content = window.contentRect(forFrameRect: window.frame).size
        preferences.windowLongSide = max(content.width, content.height)
    }

    private func screenFrames() -> [CGRect] {
        NSScreen.screens.map(\.visibleFrame)
    }

    private func startObserving() {
        guard !isObserving else { return }
        isObserving = true
        for name in [NSWindow.didMoveNotification, NSWindow.didEndLiveResizeNotification] {
            Task { [weak self] in
                guard let window = self?.window else { return }
                for await _ in NotificationCenter.default.notifications(
                    named: name,
                    object: window
                ) {
                    guard let self else { return }
                    guard let applied = appliedFrame, applied != window.frame else { continue }
                    persistFrame()
                }
            }
        }
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: fallbackContentSize),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = NSHostingController(
            rootView: ShareRootView(
                previewLayer: previewLayer, overlay: overlayModel
            )
        )
        window.delegate = self
        window.collectionBehavior.insert(.fullScreenPrimary)
        window.backgroundColor = .black
        window.hasShadow = true
        window.isReleasedWhenClosed = false
        // Tagged so WindowSharing keeps the feed capturable while excluding every
        // other window; titled so it's the clearly-named pick in a call's picker.
        window.identifier = WindowSharing.shareWindowID
        window.title = "SharePad"
        return window
    }
}

// The trial overlay lives *inside* the window's SwiftUI root (a ZStack over the
// preview) rather than as a foreign NSHostingView subview — the latter doesn't
// reliably composite above the layer-backed preview. Driven by an @Observable flag.
@MainActor
@Observable
final class ShareOverlayModel {
    var trialOverlayVisible = false
    var sessionEndsAt: Date?
    var onBuy: (() -> Void)?
    var onEnterLicense: () -> Void = {}
}

private struct ShareRootView: View {
    let previewLayer: AVCaptureVideoPreviewLayer
    let overlay: ShareOverlayModel

    var body: some View {
        ZStack {
            PreviewView(layer: previewLayer)
            if overlay.trialOverlayVisible {
                TrialOverlayView(onBuy: overlay.onBuy, onEnterLicense: overlay.onEnterLicense)
            } else if let endsAt = overlay.sessionEndsAt {
                TrialCountdownWatermark(endsAt: endsAt)
            }
        }
    }
}
