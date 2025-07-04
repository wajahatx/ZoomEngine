//
//  File.swift
//  ZoomEngine
//
//  Created by Wajahat on 10/01/2025.
//

import Foundation
import SwiftUI
import UIKit

public class SUInfinityImageViewContainer: UIView, @preconcurrency ZoomEngineDelegate {
    public func scaleValueChange(zoomValue: CGFloat) {
        delegate?.scaleValueChange(zoomValue: zoomValue)
    }
    
    public func zoomStateChange(isZooming: Bool) {
        delegate?.zoomStateChange(isZooming: isZooming)
    }
    
    private let imageView: ZoomEngineInfinityImageView
    private let cornerRadius: CGFloat
    
    weak var delegate: ZoomEngineDelegate?
    
    init(image: UIImage?, cornerRadius: CGFloat) {
        self.imageView = ZoomEngineInfinityImageView(image: image)
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        setupImageView()
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        self.imageView = ZoomEngineInfinityImageView(image: nil)
        self.cornerRadius = 0
        super.init(coder: coder)
        setupImageView()
    }
    
    private func setupImageView() {
        self.imageView.delegate = self
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func updateImage(_ image: UIImage?) {
        imageView.image = image?.withRoundedCorners(radius: cornerRadius == 0 ? nil : cornerRadius)
    }
}

public struct SUInfinityImageView: UIViewRepresentable {
    @Binding var image: UIImage?
    @Binding var isZooming: Bool
    let cornerRadius: CGFloat
    
    public init(image: Binding<UIImage?>, isZooming: Binding<Bool>, cornerRadius: CGFloat = 20) {
        self._image = image
        self._isZooming = isZooming
        self.cornerRadius = cornerRadius
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> SUInfinityImageViewContainer {
        let imageViewContainer = SUInfinityImageViewContainer(image: image, cornerRadius: cornerRadius)
        imageViewContainer.delegate = context.coordinator
        return imageViewContainer
    }
    
    public func updateUIView(_ uiView: SUInfinityImageViewContainer, context: Context) {
        uiView.updateImage(image)
    }
    
    public class Coordinator: NSObject, @preconcurrency ZoomEngineDelegate {
        public func scaleValueChange(zoomValue: CGFloat) {
            
        }
        
        @MainActor public func zoomStateChange(isZooming: Bool) {
                self.parent.isZooming = isZooming
            
        }
        
        var parent: SUInfinityImageView
        
        init(_ parent: SUInfinityImageView) {
            self.parent = parent
        }
    }
}

extension UIImage {
    func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        guard let radius else { return self }
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
            draw(in: rect)
        }
    }
}
