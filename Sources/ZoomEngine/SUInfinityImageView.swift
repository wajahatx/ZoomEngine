//
//  File.swift
//  ZoomEngine
//
//  Created by Wajahat on 10/01/2025.
//

import Foundation
import SwiftUI
import UIKit

struct SUInfinityImageView: UIViewRepresentable {
    var image: UIImage
    var contentMode: UIView.ContentMode
    @Binding var isZooming: Bool

    func makeUIView(context: Context) -> ZoomEngineInfinityImageView {
        let imageView = ZoomEngineInfinityImageView(frame: .zero)
        imageView.image = image
        imageView.contentMode = contentMode
        imageView.delegate = context.coordinator
        return imageView
    }

    func updateUIView(_ uiView: ZoomEngineInfinityImageView, context: Context) {
        uiView.image = image
        uiView.contentMode = contentMode
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, @preconcurrency ZoomEngineDelegate {
        var parent: SUInfinityImageView

        init(_ parent: SUInfinityImageView) {
            self.parent = parent
        }

        @MainActor func zoomStateChange(isZooming: Bool) {
            parent.isZooming = isZooming
        }
    }
}
