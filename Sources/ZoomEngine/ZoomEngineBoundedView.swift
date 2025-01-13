//
//  File.swift
//  ZoomEngine
//
//  Created by Wajahat on 10/01/2025.
//

import Foundation
import UIKit
public class ZoomEngineBoundedView: UIView {
    public weak var delegate: ZoomEngineDelegate?
    private var isAnimatingReset = false
    private var currentTransform: CGAffineTransform = .identity
    private var initialCenter: CGPoint = .zero
    private var initialPinchCenter: CGPoint = .zero
    private var lastScale: CGFloat = 1.0
    private var lastCenter: CGPoint = .zero
    public var minScale: CGFloat = 1.0
    public var maxScale: CGFloat = 4.0
    
    private var isHandlingGesture: Bool = false
    
    init(frame: CGRect, minimumZoom: CGFloat = 1.0, maximumZoom: CGFloat = 4.0) {
            self.minScale = minimumZoom
            self.maxScale = maximumZoom
            super.init(frame: frame)
            setupGestures()
    }
        
    convenience init() {
           self.init(frame: .zero)
    }
    required init?(coder: NSCoder) {
            self.minScale = 1.0
            self.maxScale = 4.0
            super.init(coder: coder)
            setupGestures()
    }
    
    private func setupGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        self.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            startPinch(gesture)
            self.delegate?.zoomStateChange(isZooming: true)
        case .changed:
            updateTransform(gesture)
        case .ended, .cancelled, .failed:
            endGesture()
            self.delegate?.zoomStateChange(isZooming: false)
        default:
            break
        }
    }
    
    // MARK: Gesture Handling
    private func startPinch(_ gesture: UIPinchGestureRecognizer) {
        guard !isHandlingGesture else { return }
        isHandlingGesture = true
        currentTransform = self.transform
        initialCenter = self.center
        initialPinchCenter = getCenter(gesture, targetView: self.superview) ?? .zero
        gesture.scale = lastScale
    }
    
    private func updateTransform(_ gesture: UIPinchGestureRecognizer) {
        var newScale = gesture.scale
        newScale = max(minScale, min(newScale, maxScale))
        
        let gestureCenter = getCenter(gesture, targetView: self.superview) ?? .zero
        guard isPoint(gestureCenter, insideView: self.superview) else {
            finishGesture(gesture)
            return
        }
        
        let deltaCenter = CGPoint(
            x: -(initialPinchCenter.x - gestureCenter.x),
            y: -(initialPinchCenter.y - gestureCenter.y)
        )
        
        var transform = CGAffineTransform.identity
        transform.tx = currentTransform.tx
        transform.ty = currentTransform.ty
        transform = transform.scaledBy(x: newScale, y: newScale)
        transform = transform.translatedBy(x: (deltaCenter.x / newScale), y: (deltaCenter.y / newScale))
        
        self.transform = transform
        lastScale = newScale
    }
    
    private func endGesture() {
        if !isScaledFrameFullyCoveringParent() {
            animateToValidScale()
        }
        isHandlingGesture = false
    }
    
    private func animateToValidScale() {
        UIView.animate(withDuration: 0.3, animations: {
            self.resetCenterIfOutOfBounds()
        })
    }
    
    private func finishGesture(_ gesture: UIPinchGestureRecognizer) {
        gesture.isEnabled = false
        gesture.isEnabled = true
    }
    
    private func resetCenterIfOutOfBounds() {
        guard let superview = self.superview else { return }
        let scaledFrame = self.frame
        let superviewBounds = superview.bounds
        var adjustedCenter = self.center
        
        if scaledFrame.minX > superviewBounds.minX {
            adjustedCenter.x -= (scaledFrame.minX - superviewBounds.minX)
        }
        if scaledFrame.maxX < superviewBounds.maxX {
            adjustedCenter.x += (superviewBounds.maxX - scaledFrame.maxX)
        }
        if scaledFrame.minY > superviewBounds.minY {
            adjustedCenter.y -= (scaledFrame.minY - superviewBounds.minY)
        }
        if scaledFrame.maxY < superviewBounds.maxY {
            adjustedCenter.y += (superviewBounds.maxY - scaledFrame.maxY)
        }
        
        self.center = adjustedCenter
    }
    
    private func isScaledFrameFullyCoveringParent() -> Bool {
        guard let superview = self.superview else { return false }
            let scaledFrame = self.frame
            let superviewBounds = superview.bounds
            
        return scaledFrame.minX <= superviewBounds.minX &&
                   scaledFrame.minY <= superviewBounds.minY &&
                   scaledFrame.maxX >= superviewBounds.maxX &&
                   scaledFrame.maxY >= superviewBounds.maxY
    }
    
    private func getCenter(_ gesture: UIPinchGestureRecognizer, targetView: UIView?) -> CGPoint? {
        guard let targetView = targetView else { return nil }
        
        let numberOfTouches = gesture.numberOfTouches
        guard numberOfTouches == 2 else { return lastCenter }
        
        let touch1 = gesture.location(ofTouch: 0, in: targetView)
        let touch2 = gesture.location(ofTouch: 1, in: targetView)
        
        let centerX = (touch1.x + touch2.x) / 2
        let centerY = (touch1.y + touch2.y) / 2
        let centerPoint = CGPoint(x: centerX, y: centerY)
        lastCenter = centerPoint
        return centerPoint
    }
    
    private func isPoint(_ point: CGPoint, insideView view: UIView?) -> Bool {
        guard let view = view else { return false }
        let convertedPoint = view.convert(point, to: view)
        return view.bounds.contains(convertedPoint)
    }
}
