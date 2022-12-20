// Copyright © 2022 JARMourato All rights reserved.

import SwiftUI

struct TextFieldClearButton: ViewModifier {
    @Binding var text: String

    func body(content: Content) -> some View {
        content
            .overlay {
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .onTapGesture { text = "" }
                        .opacity(text.isEmpty ? 0 : 1)
                }
            }
    }
}

extension TextField {
    public func showClearButton(_ text: Binding<String>) -> some View {
        self.modifier(TextFieldClearButton(text: text))
    }
}
