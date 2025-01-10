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
        let zoomView = ZoomEngineBoundedView(frame: .zero, minimumZoom: minScale, maximumZoom: maxScale)

        let hostingConfiguration = UIHostingConfiguration { content }
        let hostingView = hostingConfiguration.makeContentView()

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        zoomView.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: zoomView.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: zoomView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: zoomView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: zoomView.bottomAnchor)
        ])

        return zoomView
    }

    public func updateUIView(_ uiView: ZoomEngineBoundedView, context: Context) {
        uiView.minScale = minScale
        uiView.maxScale = maxScale

        if let hostingView = uiView.subviews.first {
            hostingView.removeFromSuperview()
            let newHostingConfiguration = UIHostingConfiguration { content }
            let newHostingView = newHostingConfiguration.makeContentView()

            newHostingView.translatesAutoresizingMaskIntoConstraints = false
            uiView.addSubview(newHostingView)

            NSLayoutConstraint.activate([
                newHostingView.topAnchor.constraint(equalTo: uiView.topAnchor),
                newHostingView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
                newHostingView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
                newHostingView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor)
            ])
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
