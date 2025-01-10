//
//  File.swift
//  ZoomEngine
//
//  Created by Wajahat on 10/01/2025.
//

import Foundation
import SwiftUI
import UIKit


public class SUInfinityImageViewContainer: UIView {
    
    private let imageView: ZoomEngineInfinityImageView
    private let cornerRadius: CGFloat
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
    let cornerRdius: CGFloat
    public init(image: Binding<UIImage?>, cornerRdius: CGFloat = 20) {
        self._image = image
        self.cornerRdius = cornerRdius
    }
    
    public func makeUIView(context: Context) -> SUInfinityImageViewContainer {
        let imageViewContainer = SUInfinityImageViewContainer(image: image, cornerRadius: cornerRdius)
        return imageViewContainer
    }
    
    public func updateUIView(_ uiView: SUInfinityImageViewContainer, context: Context) {
        uiView.updateImage(image)
    }
}


extension UIImage{
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
