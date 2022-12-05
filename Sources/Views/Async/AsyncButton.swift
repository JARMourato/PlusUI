// Copyright © 2022 JARMourato All rights reserved.

import SwiftUI

/// A Button that takes a some async work and handles the loading state displaying a progress view while loading.
public struct AsyncButton<Label: View>: View {
    var action: () async -> Void
    var options = Set(Option.allCases)
    @ViewBuilder var label: () -> Label

    @State private var isDisabled = false
    @State private var showProgressView = false

    public var body: some View {
        Button(action: buttonAction, label: labelView)
            .disabled(isDisabled)
    }
}

// MARK: - Label View

extension AsyncButton {
    @ViewBuilder
    private func labelView() -> some View {
        ZStack {
            label().opacity(showProgressView ? 0 : 1)
            if showProgressView {
                ProgressView()
                    .controlSize(.regular)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Action

extension AsyncButton {
    private func buttonAction() {
        if options.contains(.disableButton) {
            isDisabled = true
        }

        Task {
            var progressViewTask: Task<Void, Error>?

            if options.contains(.showProgressView) {
                progressViewTask = Task {
                    try await Task.sleep(nanoseconds: 150_000_000)
                    showProgressView = true
                }
            }

            await action()
            progressViewTask?.cancel()

            isDisabled = false
            showProgressView = false
        }
    }
}

// MARK: - Nested Types

public extension AsyncButton {
    // MARK: - Options

    enum Option: CaseIterable {
        case disableButton
        case showProgressView
    }
}

// MARK: - Convenience Initializers

public extension AsyncButton where Label == Text {
    init(_ label: String, actionOptions _: Set<Option> = Set(Option.allCases), action: @escaping () async -> Void) {
        self.init(action: action) { Text(label) }
    }
}

public extension AsyncButton where Label == Image {
    init(systemImageName: String, actionOptions _: Set<Option> = Set(Option.allCases), action: @escaping () async -> Void) {
        self.init(action: action) { Image(systemName: systemImageName) }
    }
}
