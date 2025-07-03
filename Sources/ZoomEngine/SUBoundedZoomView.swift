//
//  File.swift
//  ZoomEngine
//
//  Created by Wajahat on 10/01/2025.
//

import Foundation
import SwiftUI

public class SUBoundedZoomViewContainer: UIView, @preconcurrency ZoomEngineDelegate {
    public func zoomStateChange(isZooming: Bool) {
        delegate?.zoomStateChange(isZooming: isZooming)
    }
    
    private var containerView: ZoomEngineBoundedView?
    weak var delegate: ZoomEngineDelegate?
    
    init() {
        super.init(frame: .zero)
        setupContainer()
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContainer()
    }
    
    private func setupContainer() {
        let zoomView = ZoomEngineBoundedView()
        zoomView.delegate = self
        self.containerView = zoomView
        
        zoomView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(zoomView)
        
        NSLayoutConstraint.activate([
            zoomView.topAnchor.constraint(equalTo: topAnchor),
            zoomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            zoomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            zoomView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func addSubView(_ view: UIView) -> ZoomEngineBoundedView {
        guard let containerView else {
            return ZoomEngineBoundedView(frame: .zero)
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        return containerView
    }
    public func resetZoom(animated: Bool = true, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        containerView?.resetZoom(animated: animated, duration: duration, completion: completion)
    }
}

public struct SUBoundedZoomView<Content: View>: UIViewRepresentable {
    @Binding var isZooming: Bool
    private let content: Content
    
    @Binding var shouldResetZoom: Bool
    
    public init(isZooming: Binding<Bool>, shouldResetZoom: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isZooming = isZooming
        self._shouldResetZoom = shouldResetZoom
        self.content = content()
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> SUBoundedZoomViewContainer {
        let container = SUBoundedZoomViewContainer()
        container.clipsToBounds = true
        container.delegate = context.coordinator
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        _ = container.addSubView(hostingController.view)
        return container
    }
    
    public func updateUIView(_ uiView: SUBoundedZoomViewContainer, context: Context) {
        if shouldResetZoom {
                    uiView.resetZoom()
                    // Reset the trigger on the next run loop to avoid continuous calling
                    DispatchQueue.main.async {
                        self.shouldResetZoom = false
                    }
                }
    }
    
    public class Coordinator: NSObject, @preconcurrency ZoomEngineDelegate {
        var parent: SUBoundedZoomView
        
        init(_ parent: SUBoundedZoomView) {
            self.parent = parent
        }
        
        @MainActor public func zoomStateChange(isZooming: Bool) {
                self.parent.isZooming = isZooming
            
        }
    }
}
