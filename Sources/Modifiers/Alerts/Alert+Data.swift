// Copyright © 2022 JARMourato All rights reserved.

import SwiftUI

public struct AlertErrorData: Identifiable {
    public var id: String { error.localizedDescription }
    public let error: Error
    public let title: String

    public init(error: Error, title: String) {
        self.error = error
        self.title = title
    }
}

public struct AlertModifier: ViewModifier {
    @Binding var errorData: AlertErrorData?

    public func body(content: Content) -> some View {
        content
            .alert(item: $errorData, content: { Alert(title: $0.title, error: $0.error) })
    }
}

public extension Alert {
    /// Initializes an Alert to display an error.
    /// - Parameters:
    ///   - error: The error being displayed.
    ///   - title: The title of the alert.
    ///   - recoverySuggestion: The message to be displayed after the error message, which should help users recover from the error.
    init(title: String, error: Error, recoverySuggestion: String = "Please try again or contact an admin.") {
        self.init(
            title: Text(title),
            message: Text("\(String(describing: error)).\n\(recoverySuggestion)"),
            dismissButton: .default(Text("Ok"))
        )
    }
}

public extension View {
    func alertWith(data: Binding<AlertErrorData?>) -> some View {
        modifier(AlertModifier(errorData: data))
    }
}
