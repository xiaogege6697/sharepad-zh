import AppKit
import SwiftUI

struct PreviewView: NSViewRepresentable {
    let layer: CALayer

    func makeNSView(context _: Context) -> PreviewNSView {
        let view = PreviewNSView()
        view.wantsLayer = true
        view.hostedLayer = layer
        view.layer?.addSublayer(layer)
        return view
    }

    func updateNSView(_: PreviewNSView, context _: Context) {}
}

final class PreviewNSView: NSView {
    var hostedLayer: CALayer?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        synchronizeScale()
    }

    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        synchronizeScale()
    }

    private func synchronizeScale() {
        hostedLayer?.contentsScale = window?.backingScaleFactor ?? 1
    }

    override func layout() {
        super.layout()
        synchronizeScale()
        hostedLayer?.frame = bounds

    }
}
