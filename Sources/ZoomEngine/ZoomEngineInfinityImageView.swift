//
//  File.swift
//  ZoomEngine
//
//  Created by Wajahat on 10/01/2025.
//

import Foundation
import UIKit
public class ZoomEngineInfinityImageView: UIImageView {
    public weak var delegate: ZoomEngineDelegate?
    
    private var currentImageView: UIImageView?
    private var hostImageView: UIImageView?
    private var isAnimatingReset = false
    private var firstCenterPoint = CGPoint.zero
    private var startingRect = CGRect.zero
    private var lastPinchCenter = CGPoint.zero
    private var lastTouchPosition = CGPoint.zero
    
    var isHandlingGesture: Bool {
        return hostImageView != nil
    }
    override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
    required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
    }
    private func commonInit() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:))))
    }
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        
        gestureStateChanged(gesture, withZoomImageView: self)
    }
    public func gestureStateChanged(_ gesture: UIGestureRecognizer, withZoomImageView imageView: UIImageView) {
        guard let theGesture = gesture as? UIPinchGestureRecognizer else {
            print("Must be using a UIPinchGestureRecognizer, currently you're using a: \(gesture.self)")
            return
        }

        if isAnimatingReset {
            return
        }

        if theGesture.state == .ended || theGesture.state == .cancelled || theGesture.state == .failed {
            resetImageZoom()
            return
        }

        if isHandlingGesture && hostImageView != imageView {
            print("ignored since this imageView isn't being tracked")
            return
        }

        if !isHandlingGesture && theGesture.state == .began {
            let currentWindow = getWindow()
            firstCenterPoint = theGesture.location(in: currentWindow)

            let point = imageView.convert(imageView.bounds.origin, to: nil)
            startingRect = CGRect(x: point.x, y: point.y, width: imageView.frame.width, height: imageView.frame.height)

            currentImageView = UIImageView(image: imageView.image)
            currentImageView?.contentMode = imageView.contentMode
            currentImageView?.bounds = startingRect
            let imageViewBoundsCenter = CGPoint(x: imageView.bounds.width * 0.5, y: imageView.bounds.height * 0.5)
            currentImageView?.center = imageView.convert(imageViewBoundsCenter, to: currentWindow)
            currentWindow?.addSubview(currentImageView!)

            hostImageView = imageView
            imageView.isHidden = true
            self.delegate?.zoomStateChange(isZooming: true)
        }

        if theGesture.state == .changed {
            if theGesture.numberOfTouches == 1 {
                let currentTouchPosition = theGesture.location(ofTouch: 0, in: imageView)
            
                if lastTouchPosition == CGPoint.zero {
                    lastTouchPosition = currentTouchPosition
                    return
                }

                let translation = CGPoint(x: currentTouchPosition.x - lastTouchPosition.x, y: currentTouchPosition.y - lastTouchPosition.y)
                let newCenter = CGPoint(x: lastPinchCenter.x + translation.x, y: lastPinchCenter.y + translation.y)
                currentImageView?.center = newCenter
                lastTouchPosition = currentTouchPosition
            } else {
                let newScale = theGesture.scale
                currentImageView?.frame = CGRect(x: currentImageView!.frame.origin.x,
                                                 y: currentImageView!.frame.origin.y,
                                                 width: startingRect.width * newScale,
                                                 height: startingRect.height * newScale)

                let currentWindow = getWindow()
                let centerXDif = (firstCenterPoint.x - theGesture.location(in: currentWindow).x) + (firstCenterPoint.x.distance(to: startingRect.midX) * (1-newScale))
                let centerYDif = (firstCenterPoint.y - theGesture.location(in: currentWindow).y) + (firstCenterPoint.y.distance(to: startingRect.midY) * (1-newScale))
                currentImageView?.center = CGPoint(x: (startingRect.origin.x + (startingRect.size.width / 2)) - centerXDif,
                                                   y: (startingRect.origin.y + (startingRect.size.height / 2)) - centerYDif)
                
                lastTouchPosition = CGPoint.zero
            }

            lastPinchCenter = currentImageView?.center ?? CGPoint.zero
        }
    }
    private func getWindow() -> UIWindow? {
        UIApplication
        .shared
        .connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
        
    }
    
    public func resetImageZoom() {
        if isAnimatingReset || !isHandlingGesture {
            return
        }
        
        isAnimatingReset = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.currentImageView?.frame = self.startingRect
        }, completion: { finished in
            self.currentImageView?.removeFromSuperview()
            self.currentImageView = nil
            self.hostImageView?.isHidden = false
            self.hostImageView = nil
            self.startingRect = CGRect.zero
            self.firstCenterPoint = CGPoint.zero
            self.isAnimatingReset = false
            self.delegate?.zoomStateChange(isZooming: false)
        })
    }
}


