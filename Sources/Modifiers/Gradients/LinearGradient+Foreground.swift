// Copyright © 2022 JARMourato All rights reserved.

import SwiftUI

public extension View {
    func foregroundLinearGradient(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) -> some View {
        overlay {
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
            .mask(self)
        }
    }
}
