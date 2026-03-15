import XCTest

final class ConcurrencyArchitectureAppTests: XCTestCase {
    func testDashboardRepositoryCoalescesInFlightRequests() async throws {
        let api = CountingObservabilityAPI()
        let repository = DashboardRepository(api: api)

        async let first = repository.dashboard()
        async let second = repository.dashboard()

        _ = try await (first, second)

        let counters = await api.counters()
        XCTAssertEqual(counters.trendingCalls, 1)
        XCTAssertEqual(counters.healthCalls, 1)
        XCTAssertEqual(counters.eventsCalls, 1)
    }

    func testSearchRepositoryCachesPreviewLookups() async throws {
        let api = CountingObservabilityAPI()
        let repository = SearchRepository(api: api)

        _ = try await repository.search(query: "actor")
        _ = try await repository.search(query: "actor")

        let counters = await api.counters()
        XCTAssertEqual(counters.searchCalls, 2)
        XCTAssertEqual(counters.previewCalls, 1)
    }
}

actor CountingObservabilityAPI: ObservabilityAPI {
    private var trendingCalls = 0
    private var healthCalls = 0
    private var eventsCalls = 0
    private var searchCalls = 0
    private var previewCalls = 0

    func fetchTrendingTopics() async throws -> [Topic] {
        trendingCalls += 1
        try await Task.sleep(for: .milliseconds(50))
        return [Topic(id: UUID(), title: "Structured concurrency", score: 99)]
    }

    func fetchTeamHealth() async throws -> TeamHealth {
        healthCalls += 1
        return TeamHealth(activeIncidents: 1, respondersOnline: 4, automationCoverage: 70)
    }

    func fetchRecentEvents() async throws -> [ActivityEvent] {
        eventsCalls += 1
        return [ActivityEvent(id: UUID(), title: "Refreshed", relativeTime: "Now")]
    }

    func searchTopics(matching query: String) async throws -> [Topic] {
        searchCalls += 1
        return [Topic(id: stableID, title: "Actor isolation", score: 95)]
    }

    func fetchPreview(for topic: Topic) async throws -> String {
        previewCalls += 1
        return "Cached preview"
    }

    func counters() -> (trendingCalls: Int, healthCalls: Int, eventsCalls: Int, searchCalls: Int, previewCalls: Int) {
        (trendingCalls, healthCalls, eventsCalls, searchCalls, previewCalls)
    }

    private var stableID: UUID {
        UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
    }
}
