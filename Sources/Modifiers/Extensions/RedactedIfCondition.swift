// Copyright © 2022 JARMourato All rights reserved.

import SwiftUI

public extension View {
    
    @ViewBuilder
    func redacted(if condition: @autoclosure () -> Bool) -> some View {
        redacted(reason: condition() ? .placeholder : [])
    }
}
