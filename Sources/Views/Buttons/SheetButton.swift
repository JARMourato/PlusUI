// Copyright © 2022 JARMourato All rights reserved.

import SwiftUI

public struct SheetButton<Label, Content>: View where Label: View, Content: View {
    var label: () -> Label
    var target: () -> Content
    @State var isPresented = false

    public init(@ViewBuilder label: @escaping () -> Label, @ViewBuilder target: @escaping () -> Content) {
        self.label = label
        self.target = target
    }

    public var body: some View {
        Button(action: { self.isPresented.toggle() }, label: label)
            .sheet(isPresented: $isPresented, content: target)
    }
}
