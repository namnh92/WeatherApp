//
//  AsyncDebouncer.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

protocol IAsyncDebouncer {
    func schedule(_ action: @escaping @Sendable () async -> Void)
    func cancel()
}

class AsyncDebouncer: IAsyncDebouncer {
    private let delay: UInt64
    private var task: Task<Void, Never>?

    init(delay: TimeInterval) {
        self.delay = UInt64(delay * 1_000_000_000)
    }

    func schedule(_ action: @escaping @Sendable () async -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(nanoseconds: delay)
            guard !Task.isCancelled else { return }
            await action()
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
