import Foundation

/// Serializes dashboard state and ensures callers either receive cached data
/// or await the same in-flight task instead of starting duplicate work.
actor DashboardRepository {
    private let api: ObservabilityAPI
    private var cachedSnapshot: DashboardSnapshot?
    private var inFlightSnapshotTask: Task<DashboardSnapshot, Error>?

    init(api: ObservabilityAPI) {
        self.api = api
    }

    func dashboard(forceRefresh: Bool = false) async throws -> DashboardSnapshot {
        if !forceRefresh, let cachedSnapshot {
            return cachedSnapshot
        }

        // Coalesce concurrent reads so pull-to-refresh and initial load can safely overlap.
        if let inFlightSnapshotTask {
            return try await inFlightSnapshotTask.value
        }

        let task = Task { [api] in
            // Independent dependencies fan out in parallel and rejoin as one snapshot.
            async let topics = api.fetchTrendingTopics()
            async let health = api.fetchTeamHealth()
            async let events = api.fetchRecentEvents()

            return try await DashboardSnapshot(
                generatedAt: .now,
                trendingTopics: topics,
                teamHealth: health,
                recentEvents: events
            )
        }

        inFlightSnapshotTask = task

        do {
            let snapshot = try await task.value
            cachedSnapshot = snapshot
            inFlightSnapshotTask = nil
            return snapshot
        } catch {
            inFlightSnapshotTask = nil
            throw error
        }
    }
}
