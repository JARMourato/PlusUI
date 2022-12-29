// Copyright © 2022 JARMourato All rights reserved.

import Foundation

@MainActor
public final class ViewModel<Value>: ObservableObject {
    
    /// Represents the state of the viewModel
    @frozen public enum State<Value> {
        case failure(Error), loaded(Value), noData
    }
    
    private var asyncWork: () async throws -> Value
    private var isLoading: Bool = false
    @Published private(set) var result = State<Value>.noData
    
    public init(_ work: @escaping () async throws -> Value) {
        asyncWork = work
    }

    private func runAsyncWork() async throws -> Value {
        try await asyncWork()
    }

    @Sendable
    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            result = .loaded(try await runAsyncWork())
        } catch {
            result = .failure(error)
        }
    }

    @Sendable
    public func loadIfNeeded() async {
        switch result {
        case .noData, .failure: await load()
        case .loaded: break
        }
    }
}
