// Copyright © 2022 JARMourato All rights reserved.

import SwiftUI

public struct FluidGradient: View {
    private var blobs: [Color]
    private var blur: CGFloat
    @State var blurValue: CGFloat = 0.0
    private var highlights: [Color]
    private var speed: CGFloat

    public init(blobs: [Color], highlights: [Color] = [], speed: CGFloat = 1.0, blur: CGFloat = 0.75) {
        self.blobs = blobs
        self.blur = blur
        self.highlights = highlights
        self.speed = speed
    }

    public var body: some View {
        Representable(
            blobs: blobs,
            highlights: highlights,
            speed: speed,
            blurValue: $blurValue
        )
        .blur(radius: pow(blurValue, blur))
        .accessibility(hidden: true)
        .clipped()
    }
}

#if os(OSX)
typealias SystemRepresentable = NSViewRepresentable
#else
typealias SystemRepresentable = UIViewRepresentable
#endif

// MARK: - Representable
extension FluidGradient {
    struct Representable: SystemRepresentable {
        var blobs: [Color]
        var highlights: [Color]
        var speed: CGFloat

        @Binding var blurValue: CGFloat

        func makeView(context: Context) -> FluidGradientView {
            context.coordinator.view
        }

        func updateView(_ view: FluidGradientView, context: Context) {
            context.coordinator.create(blobs: blobs, highlights: highlights)
            DispatchQueue.main.async {
                context.coordinator.update(speed: speed)
            }
        }

#if os(OSX)
        func makeNSView(context: Context) -> FluidGradientView {
            makeView(context: context)
        }
        func updateNSView(_ view: FluidGradientView, context: Context) {
            updateView(view, context: context)
        }
#else
        func makeUIView(context: Context) -> FluidGradientView {
            makeView(context: context)
        }
        func updateUIView(_ view: FluidGradientView, context: Context) {
            updateView(view, context: context)
        }
#endif

        func makeCoordinator() -> Coordinator {
            Coordinator(blobs: blobs, highlights: highlights, speed: speed, blurValue: $blurValue)
        }
    }

    class Coordinator: FluidGradientDelegate {
        var blobs: [Color]
        var blurValue: Binding<CGFloat>
        var highlights: [Color]
        var speed: CGFloat
        var view: FluidGradientView

        init(blobs: [Color], highlights: [Color], speed: CGFloat, blurValue: Binding<CGFloat>) {
            self.blobs = blobs
            self.blurValue = blurValue
            self.highlights = highlights
            self.speed = speed
            self.view = FluidGradientView(blobs: blobs, highlights: highlights, speed: speed)
            self.view.delegate = self
        }

        func create(blobs: [Color], highlights: [Color]) {
            guard blobs != self.blobs || highlights != self.highlights else { return }
            self.blobs = blobs
            self.highlights = highlights

            view.create(blobs, layer: view.baseLayer)
            view.create(highlights, layer: view.highlightLayer)
            view.update(speed: speed)
        }

        func update(speed: CGFloat) {
            guard speed != self.speed else { return }
            self.speed = speed
            view.update(speed: speed)
        }

        func updateBlur(_ value: CGFloat) {
            blurValue.wrappedValue = value
        }
    }
}
