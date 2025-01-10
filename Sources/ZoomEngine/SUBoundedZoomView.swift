//
//  File.swift
//  ZoomEngine
//
//  Created by Wajahat on 10/01/2025.
//

import Foundation
import SwiftUI

public struct SUBoundedZoomView<Content: View>: UIViewRepresentable {
    var minScale: CGFloat
    var maxScale: CGFloat
    var content: Content
    
    public init(minScale: CGFloat = 1.0, maxScale: CGFloat = 4.0, @ViewBuilder content: () -> Content) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.content = content()
    }
    
    public func makeUIView(context: Context) -> ZoomEngineBoundedView {
        let hostingController = UIHostingController(rootView: content)
        let zoomView = ZoomEngineBoundedView(frame: .zero, minimumZoom: minScale, maximumZoom: maxScale)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        zoomView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: zoomView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: zoomView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: zoomView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: zoomView.bottomAnchor)
        ])
        
        return zoomView
    }
    
    public func updateUIView(_ uiView: ZoomEngineBoundedView, context: Context) {
        uiView.minScale = minScale
        uiView.maxScale = maxScale
        
        if let hostingView = uiView.subviews.first,
           let hostingController = hostingView.next as? UIHostingController<Content> {
            hostingController.rootView = content
        }
    }
}

public extension View {
    func zoomable(minScale: CGFloat = 1.0, maxScale: CGFloat = 4.0) -> some View {
        SUBoundedZoomView(minScale: minScale, maxScale: maxScale) {
            self
        }
        .clipShape(Rectangle()) 
    }
}
