// The Swift Programming Language
// https://docs.swift.org/swift-book

import CoreGraphics
public protocol ZoomEngineDelegate: AnyObject {
    func zoomStateChange(isZooming: Bool)
    func scaleValueChange(zoomValue: CGFloat)
}
