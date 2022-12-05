// Copyright © 2022 JARMourato All rights reserved.

import SwiftUI

/// A view that takes a some async work and handles the states from empty to loaded, displaying a progress view while loading.
public struct AsyncView<Value, Content: View, Failure: View, Progress: View>: View {
    private let content: (_ item: Value) -> Content
    private let failure: (_ error: Error) -> Failure
    private let options: Set<Option>
    private let progress: () -> Progress
    @StateObject private var model: Model<Value>

    public init(
        asyncWork: @escaping () async throws -> Value,
        @ViewBuilder content: @escaping (_ value: Value) -> Content,
        @ViewBuilder failure: @escaping (_ error: Error) -> Failure,
        @ViewBuilder progress: @escaping () -> Progress = { ProgressView() },
        options: Set<Option> = Set<Option>(Option.allCases)
    ) {
        self.content = content
        self.failure = failure
        self.options = options
        self.progress = progress
        _model = StateObject(wrappedValue: Model(asyncWork))
    }

    public var body: some View {
        refreshableView.task(model.loadIfNeeded)
    }
}

// MARK: - Handling state and refreshable

extension AsyncView {
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
        case .ready: Text("") // Placeholder view
        case .loading: progress()
        case let .loaded(value): content(value)
        case let .failure(error): failure(error)
        }
    }
}

// MARK: - Nested Types

extension AsyncView {
    // MARK: - View Configuration Options

    public enum Option: CaseIterable {
        case refreshable
    }

    // MARK: - View State

    /// Represents the state of the view
    @frozen enum State<Value> {
        case ready, loading, loaded(Value), failure(Error)
    }

    // MARK: - View Model

    @MainActor
    final class Model<Value>: ObservableObject {
        private var asyncWork: () async throws -> Value
        @Published private(set) var result = State<Value>.ready

        init(_ work: @escaping () async throws -> Value) {
            asyncWork = work
        }

        private func runAsyncWork() async throws -> Value {
            try await asyncWork()
        }

        @Sendable
        func load() async {
            if case .loading = result { return }
            result = .loading

            do {
                result = .loaded(try await runAsyncWork())
            } catch {
                result = .failure(error)
            }
        }

        @Sendable
        func loadIfNeeded() async {
            switch result {
            case .ready, .failure: await load()
            case .loading, .loaded: break
            }
        }
    }
}
