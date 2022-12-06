// Copyright © 2022 JARMourato All rights reserved.

import Combine
import Extensions
import SwiftUI

class FluidGradientView: SystemView {
    let baseLayer = ResizableLayer()
    var cancellables = Set<AnyCancellable>()
    weak var delegate: FluidGradientDelegate?
    let highlightLayer = ResizableLayer()
    var speed: CGFloat

    init(blobs: [Color] = [], highlights: [Color] = [], speed: CGFloat = 1.0) {
        self.speed = speed
        super.init(frame: .zero)
        if let compositingFilter = CIFilter(name: "CIOverlayBlendMode") {
            highlightLayer.compositingFilter = compositingFilter
        }
        #if os(OSX)
            layer = ResizableLayer()
            wantsLayer = true
            postsFrameChangedNotifications = true
            layer?.delegate = self
            baseLayer.delegate = self
            highlightLayer.delegate = self
            layer?.addSublayer(baseLayer)
            layer?.addSublayer(highlightLayer)
        #else
            layer.addSublayer(baseLayer)
            layer.addSublayer(highlightLayer)
        #endif
        create(blobs, layer: baseLayer)
        create(highlights, layer: highlightLayer)
        DispatchQueue.main.async { self.update(speed: speed) }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func create(_ colors: [Color], layer: CALayer) {
        let count = layer.sublayers?.count ?? 0
        let removeCount = count - colors.count
        if removeCount > 0 { layer.sublayers?.removeLast(removeCount) }

        for (index, color) in colors.enumerated() {
            if index < count {
                if let existing = layer.sublayers?[index] as? BlobLayer {
                    existing.set(color: color)
                }
            } else {
                layer.addSublayer(BlobLayer(color: color))
            }
        }
    }

    public func update(speed: CGFloat) {
        cancellables.removeAll()
        self.speed = speed
        guard speed > 0 else { return }

        let layers = (baseLayer.sublayers ?? []) + (highlightLayer.sublayers ?? [])
        for layer in layers {
            if let layer = layer as? BlobLayer {
                Timer.publish(every: .random(in: 0.8 / speed ... 1.2 / speed), on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in
                        #if os(OSX)
                            let visible = self.window?.occlusionState.contains(.visible)
                            guard visible == true else { return }
                        #endif
                        layer.animate(speed: speed)
                    }
                    .store(in: &cancellables)
            }
        }
    }

    private func updateBlur() {
        delegate?.updateBlur(min(frame.width, frame.height))
    }

    #if os(OSX)
        override public func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            let scale = window?.backingScaleFactor ?? 2
            layer?.contentsScale = scale
            baseLayer.contentsScale = scale
            highlightLayer.contentsScale = scale
            updateBlur()
        }

        override public func resize(withOldSuperviewSize _: NSSize) {
            updateBlur()
        }
    #else
        override public func layoutSubviews() {
            layer.frame = bounds
            baseLayer.frame = bounds
            highlightLayer.frame = bounds
            updateBlur()
        }
    #endif
}

protocol FluidGradientDelegate: AnyObject {
    func updateBlur(_ value: CGFloat)
}

#if os(OSX)
    extension FluidGradientView: CALayerDelegate, NSViewLayerContentScaleDelegate {
        public func layer(_: CALayer, shouldInheritContentsScale _: CGFloat, from _: NSWindow) -> Bool {
            true
        }
    }
#endif
