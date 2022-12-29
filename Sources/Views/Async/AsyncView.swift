// Copyright © 2022 JARMourato All rights reserved.

import SwiftUI

/// A view that takes a some async work and handles the states from empty to loaded, displaying a progress view while loading.
public struct AsyncView<Value, Content: View, Failure: View, Progress: View>: View {
    private let content: (_ item: Value) -> Content
    private let failure: (_ error: Error) -> Failure
    private let options: Set<AsyncViewOption>
    private let progress: () -> Progress

    @StateObject private var model: ViewModel<Value>

    public init(
        asyncWork: @escaping () async throws -> Value,
        options: Set<AsyncViewOption> = Set<AsyncViewOption>(AsyncViewOption.allCases),
        @ViewBuilder content: @escaping (_ value: Value) -> Content,
        @ViewBuilder failure: @escaping (_ error: Error) -> Failure,
        @ViewBuilder progress: @escaping () -> Progress = { ProgressView() }
    ) {
        self.content = content
        self.failure = failure
        self.options = options
        self.progress = progress
        _model = StateObject(wrappedValue: ViewModel(asyncWork))
    }

    // MARK: Main view

    public var body: some View {
        AsyncModelView(
            viewModel: model,
            options: options,
            content: content,
            failure: failure,
            progress: progress
        )
    }
}

/// A view that takes a some async view model and handles the states from empty to loaded, displaying a progress view while loading.
public struct AsyncModelView<Value, Content: View, Failure: View, Progress: View>: View {
    private let content: (_ item: Value) -> Content
    private let failure: (_ error: Error) -> Failure
    private let options: Set<AsyncViewOption>
    private let progress: () -> Progress

    @ObservedObject private var model: ViewModel<Value>

    public init(
        viewModel: ViewModel<Value>,
        options: Set<AsyncViewOption> = Set<AsyncViewOption>(AsyncViewOption.allCases),
        @ViewBuilder content: @escaping (_ value: Value) -> Content,
        @ViewBuilder failure: @escaping (_ error: Error) -> Failure,
        @ViewBuilder progress: @escaping () -> Progress = { ProgressView() }
    ) {
        self.content = content
        self.failure = failure
        self.options = options
        self.progress = progress
        model = viewModel
    }

    // MARK: Main view

    public var body: some View {
        refreshableView.task(model.loadIfNeeded)
    }
}

// MARK: - Handling state and refreshable

extension AsyncModelView {
    @ViewBuilder
    private var refreshableView: some View {
        if options.contains(.refreshable) {
            stateBasedView.refreshable(action: model.load)
        } else {
            stateBasedView
        }
    }

    @ViewBuilder
    private var stateBasedView: some View {
        switch model.result {
        case .noData: progress()
        case let .loaded(value): content(value)
        case let .failure(error): failure(error)
        }
    }
}

// MARK: - View Configuration Options

public enum AsyncViewOption: CaseIterable {
    case refreshable
}
