import Foundation

/// A tiny actor wrapper around `AsyncStream` so user input can be sent safely
/// from the main actor while the consumer loop lives in a background task.
actor QueryChannel {
    private var continuation: AsyncStream<String>.Continuation?

    lazy var stream: AsyncStream<String> = {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.continuation = continuation
        }
    }()

    func send(_ query: String) {
        continuation?.yield(query)
    }
}
