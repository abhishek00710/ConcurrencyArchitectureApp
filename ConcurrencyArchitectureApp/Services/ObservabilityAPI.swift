import Foundation

protocol ObservabilityAPI: Sendable {
    func fetchTrendingTopics() async throws -> [Topic]
    func fetchTeamHealth() async throws -> TeamHealth
    func fetchRecentEvents() async throws -> [ActivityEvent]
    func searchTopics(matching query: String) async throws -> [Topic]
    func fetchPreview(for topic: Topic) async throws -> String
}

struct MockObservabilityAPI: ObservabilityAPI {
    func fetchTrendingTopics() async throws -> [Topic] {
        try await Task.sleep(for: .milliseconds(500))
        return [
            Topic(id: UUID(), title: "Realtime sync", score: generateRandomNumberBetween(lower: 70, upper: 100)),
            Topic(id: UUID(), title: "Priority escalations", score: generateRandomNumberBetween(lower: 70, upper: 100)),
            Topic(id: UUID(), title: "Background refresh", score: generateRandomNumberBetween(lower: 70, upper: 100))
        ]
    }
    
    func generateRandomNumberBetween(lower: Int, upper: Int) -> Int {
        return Int.random(in: lower...upper)
    }

    func fetchTeamHealth() async throws -> TeamHealth {
        try await Task.sleep(for: .milliseconds(250))
        return TeamHealth(
            activeIncidents: generateRandomNumberBetween(lower: 1, upper: 10),
            respondersOnline: generateRandomNumberBetween(lower: 1, upper: 10),
            automationCoverage: generateRandomNumberBetween(lower: 1, upper: 10)
        )
    }

    func fetchRecentEvents() async throws -> [ActivityEvent] {
        try await Task.sleep(for: .milliseconds(350))
        return [
            ActivityEvent(id: UUID(), title: "Actor cache warmed", relativeTime: "1m ago"),
            ActivityEvent(id: UUID(), title: "Task group completed", relativeTime: "3m ago"),
            ActivityEvent(id: UUID(), title: "Search stream resumed", relativeTime: "6m ago")
        ]
    }

    func searchTopics(matching query: String) async throws -> [Topic] {
        try await Task.sleep(for: .milliseconds(220))

        let corpus = [
            "Structured concurrency",
            "Task cancellation",
            "AsyncSequence pipelines",
            "Actor isolation",
            "Task groups",
            "MainActor view models",
            "In-flight request coalescing",
            "Sendable data flow"
        ]

        return corpus
            .filter { query.isEmpty ? false : $0.localizedCaseInsensitiveContains(query) }
            .enumerated()
            .map { index, title in
                Topic(id: UUID(), title: title, score: max(50, 100 - (index * 7)))
            }
    }

    func fetchPreview(for topic: Topic) async throws -> String {
        try await Task.sleep(for: .milliseconds(120))
        return "Score \(topic.score) • safe to pass across tasks • preview loaded in parallel"
    }
}
