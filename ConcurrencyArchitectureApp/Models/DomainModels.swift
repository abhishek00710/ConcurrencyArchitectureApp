import Foundation

/// Immutable domain values shared across actors and tasks.
/// Keeping these models `Sendable` makes cross-concurrency boundaries explicit.
struct Topic: Identifiable, Sendable, Hashable {
    let id: UUID
    let title: String
    let score: Int
}

struct TeamHealth: Sendable, Hashable {
    let activeIncidents: Int
    let respondersOnline: Int
    let automationCoverage: Int
}

struct ActivityEvent: Identifiable, Sendable, Hashable {
    let id: UUID
    let title: String
    let relativeTime: String
}

struct DashboardSnapshot: Sendable, Hashable {
    let generatedAt: Date
    let trendingTopics: [Topic]
    let teamHealth: TeamHealth
    let recentEvents: [ActivityEvent]
}

struct SearchMatch: Identifiable, Sendable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let preview: String
}
