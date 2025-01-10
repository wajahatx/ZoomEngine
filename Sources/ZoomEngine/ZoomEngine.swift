// The Swift Programming Language
// https://docs.swift.org/swift-book
public protocol ZoomEngineDelegate: AnyObject {
    func zoomStateChange(isZooming: Bool)
}
