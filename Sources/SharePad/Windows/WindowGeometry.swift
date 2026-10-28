import CoreGraphics

/// Placeholder content size used before any video frame has reported real dimensions
/// (and as the window's throwaway initial frame). Replaced as soon as a frame arrives.
let fallbackContentSize = CGSize(width: 600, height: 800)

func fittedContentSize(for videoSize: CGSize, maxLongSide: CGFloat = 900) -> CGSize {
    let longSide = max(videoSize.width, videoSize.height)
    guard longSide > 0 else { return fallbackContentSize }
    let scale = min(1, maxLongSide / longSide)
    return CGSize(width: videoSize.width * scale, height: videoSize.height * scale)
}

/// nil means the saved frame's monitor is gone — the caller should centre instead.
func placedOrigin(savedOrigin: CGPoint, size: CGSize, onScreens screens: [CGRect]) -> CGPoint? {
    let rect = CGRect(origin: savedOrigin, size: size)
    guard let screen = screens.max(by: { intersectionArea($0, rect) < intersectionArea($1, rect) }),
          intersectionArea(screen, rect) > 0
    else { return nil }
    return clamped(savedOrigin, size: size, within: screen)
}

func centeredResizeOrigin(oldFrame: CGRect, newSize: CGSize,
                          onScreens screens: [CGRect]) -> CGPoint {
    let center = CGPoint(x: oldFrame.midX, y: oldFrame.midY)
    let origin = CGPoint(x: center.x - newSize.width / 2, y: center.y - newSize.height / 2)
    return placedOrigin(savedOrigin: origin, size: newSize, onScreens: screens) ?? origin
}

private func intersectionArea(_ lhs: CGRect, _ rhs: CGRect) -> CGFloat {
    let overlap = lhs.intersection(rhs)
    return overlap.isNull ? 0 : overlap.width * overlap.height
}

private func clamped(_ origin: CGPoint, size: CGSize, within screen: CGRect) -> CGPoint {
    let maxX = max(screen.minX, screen.maxX - size.width)
    let maxY = max(screen.minY, screen.maxY - size.height)
    return CGPoint(
        x: min(max(origin.x, screen.minX), maxX),
        y: min(max(origin.y, screen.minY), maxY)
    )
}

func quickResizeFrame(current: CGRect, visible: CGRect, scale: CGFloat?) -> CGRect {
    guard current.width > 0, current.height > 0 else { return current }
    let available = visible.insetBy(dx: 12, dy: 12)
    guard available.width > 0, available.height > 0 else { return current }
    let maximum = min(available.width / current.width, available.height / current.height)
    let minimum = min(max(320 / current.width, 240 / current.height), maximum)
    let factor = min(max(scale ?? maximum, minimum), maximum)
    let size = CGSize(width: current.width * factor, height: current.height * factor)
    let origin = CGPoint(
        x: min(max(current.midX - size.width / 2, available.minX), available.maxX - size.width),
        y: min(max(current.midY - size.height / 2, available.minY), available.maxY - size.height)
    )
    return CGRect(origin: origin, size: size)
}

func nativeContentSize(video: CGSize, available: CGSize, longSide: CGFloat) -> CGSize {
    guard video.width > 0, video.height > 0, available.width > 0, available.height > 0 else {
        return fallbackContentSize
    }
    let factor = min(available.width / video.width, available.height / video.height,
                     longSide / max(video.width, video.height))
    return CGSize(width: video.width * factor, height: video.height * factor)
}
