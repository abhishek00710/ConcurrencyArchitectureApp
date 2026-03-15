import Foundation

actor PreviewCache {
    private var values: [UUID: String] = [:]

    func value(for id: UUID) -> String? {
        values[id]
    }

    func insert(_ value: String, for id: UUID) {
        values[id] = value
    }
}
