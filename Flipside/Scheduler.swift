import Foundation

protocol Cancellable {
    func cancel()
}

protocol Scheduler {
    @MainActor
    @discardableResult
    func schedule(after delay: TimeInterval, _ action: @escaping @MainActor () -> Void) -> Cancellable
}

private final class TaskCancellable: Cancellable {
    private let task: Task<Void, Never>

    init(task: Task<Void, Never>) {
        self.task = task
    }

    func cancel() {
        task.cancel()
    }
}

struct DefaultScheduler: Scheduler {
    @MainActor
    func schedule(after delay: TimeInterval, _ action: @escaping @MainActor () -> Void) -> Cancellable {
        let task = Task { @MainActor in
            let nanoseconds = UInt64(max(0, delay) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            action()
        }
        return TaskCancellable(task: task)
    }
}
