//
//  File.swift
//  ZoomEngine
//
//  Created by Wajahat on 10/01/2025.
//

import Foundation
import SwiftUI


public class SUBoundedZoomViewContainer: UIView {
    
    private var containerView: ZoomEngineBoundedView?
    
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
}


public extension View {
    func boundedZoomable(minScale: CGFloat = 1.0, maxScale: CGFloat = 4.0) -> some View {
        SUBoundedZoomView { self }
        .clipShape(Rectangle())
    }
}



public struct SUBoundedZoomView<Content: View>: UIViewRepresentable {
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public func makeUIView(context: Context) -> SUBoundedZoomViewContainer {
        let container = SUBoundedZoomViewContainer()
        container.clipsToBounds = true
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        _ = container.addSubView(hostingController.view)
        return container
    }
    
    public func updateUIView(_ uiView: SUBoundedZoomViewContainer, context: Context) {
    }
}



