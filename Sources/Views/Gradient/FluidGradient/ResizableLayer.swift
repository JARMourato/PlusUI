// Copyright © 2022 JARMourato All rights reserved.

import SwiftUI

/// An implementation of ``CALayer`` that resizes its sublayers
class ResizableLayer: CALayer {
    override init() {
        super.init()
        #if os(OSX)
            autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        #endif
        sublayers = []
    }

    override public init(layer: Any) {
        super.init(layer: layer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSublayers() {
        super.layoutSublayers()
        sublayers?.forEach { layer in
            layer.frame = self.frame
        }
    }
}
