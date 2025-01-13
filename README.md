# ZoomEngine

ZoomEngine is a Swift package that provides powerful zooming capabilities for images and views in SwiftUI and UIKit. It includes components for infinite zooming and bounded zooming to suit various use cases.

## Features
- Infinite zooming with `SUInfinityImageView`.
- Bounded zooming with `SUBoundedZoomView`.
- Seamless integration with SwiftUI using `UIViewRepresentable`.
- Delegate-based communication to handle zoom state changes.

## Installation

### Swift Package Manager
Add ZoomEngine to your project using Swift Package Manager:

1. Open your project in Xcode.
2. Go to **File > Add Packages**.
3. Enter the repository URL: `https://github.com/wajahatx/ZoomEngine`.
4. Choose the package and add it to your target.

## Usage

### Importing the Library
```swift
import ZoomEngine
```

### Example: Using `SUInfinityImageView` and `SUBoundedZoomView`

The following example demonstrates how to use `SUInfinityImageView` for infinite zooming and `SUBoundedZoomView` for bounded zooming in a SwiftUI view.

#### Code Sample
```swift
import SwiftUI
import ZoomEngine

struct ContentView: View {
    @State var height: CGFloat?
    @State var width: CGFloat?
    @State private var isZooming: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Infinite Zooming Image View
            SUInfinityImageView(image: .constant(.test), isZooming: $isZooming, cornerRadius: 0)

            // Bounded Zooming View
            SUBoundedZoomView(isZooming: $isZooming, content: {
                ZStack {
                    Image(.test)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        self.width = geo.size.width
                                        self.height = geo.size.height
                                    }
                            }
                        )
                }
            })
            .frame(maxWidth: width ?? .infinity, maxHeight: height ?? .infinity)
            .clipped()
            .onChange(of: isZooming) { oldValue, newValue in
                print("Zoom state changed: \(newValue)")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
```

#### Code Explanation

1. **Infinite Zooming**:
   - `SUInfinityImageView` is used to create an image view that allows infinite zooming.
   - Bind the `isZooming` state to track whether the user is actively zooming.

2. **Bounded Zooming**:
   - `SUBoundedZoomView` provides zooming within defined bounds.
   - Use the `content` closure to define the view that will be zoomable.
   - `GeometryReader` captures the size of the container view for dynamic layout adjustments.

3. **Zoom State Handling**:
   - `onChange(of: isZooming)` monitors zoom state changes and prints the new value.

## License

This library is licensed under the MIT License. See the [LICENSE](https://github.com/your-repo/ZoomEngine/blob/main/LICENSE) file for details.

## Contributions

Contributions are welcome! Please feel free to submit a pull request or open an issue to report bugs or suggest new features.

