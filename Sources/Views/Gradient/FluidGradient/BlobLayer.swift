// Copyright © 2022 JARMourato All rights reserved.

import Extensions
import SwiftUI

class BlobLayer: CAGradientLayer {
    init(color: Color) {
        super.init()
        type = .radial
#if os(OSX)
        autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
#endif
        set(color: color)
        let position = newPosition() // Center point
        startPoint = position
        let radius = newRadius()
        endPoint = position.displace(by: radius)
    }

    func newPosition() -> CGPoint {
        CGPoint(x: CGFloat.random(in: 0.0...1.0), y: CGFloat.random(in: 0.0...1.0)).capped()
    }

    func newRadius() -> CGPoint {
        let size = CGFloat.random(in: 0.15...0.75)
        let viewRatio = frame.width/frame.height
        let safeRatio = max(viewRatio.isNaN ? 1 : viewRatio, 1)
        let ratio = safeRatio*CGFloat.random(in: 0.25...1.75)
        return CGPoint(x: size, y: size*ratio)
    }

    func animate(speed: CGFloat) {
        guard speed > 0 else { return }

        self.removeAllAnimations()
        let currentLayer = presentation() ?? self

        let animation = CASpringAnimation()
        animation.mass = 10/speed
        animation.damping = 50
        animation.duration = 1/speed

        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards

        let position = newPosition()
        let radius = newRadius()

        // Center point
        let start = animation.copy() as! CASpringAnimation
        start.keyPath = "startPoint"
        start.fromValue = currentLayer.startPoint
        start.toValue = position

        // Radius
        let end = animation.copy() as! CASpringAnimation
        end.keyPath = "endPoint"
        end.fromValue = currentLayer.endPoint
        end.toValue = position.displace(by: radius)

        startPoint = position
        endPoint = position.displace(by: radius)

        // Opacity
        let value = Float.random(in: 0.5...1)
        let opacity = animation.copy() as! CASpringAnimation
        opacity.fromValue = self.opacity
        opacity.toValue = value

        self.opacity = value

        add(opacity, forKey: "opacity")
        add(start, forKey: "startPoint")
        add(end, forKey: "endPoint")
    }

    func set(color: Color) {
        // Converted to the system color so that cgColor isn't nil
        colors = [SystemColor(color).cgColor, SystemColor(color).cgColor, SystemColor(color.opacity(0.0)).cgColor]
        locations = [0.0, 0.9, 1.0]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(layer: Any) {
        super.init(layer: layer)
    }
}
