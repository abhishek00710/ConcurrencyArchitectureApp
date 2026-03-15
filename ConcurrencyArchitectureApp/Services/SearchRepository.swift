import Foundation

/// Builds search results off the main actor and enriches each match in parallel.
actor SearchRepository {
    private let api: ObservabilityAPI
    private let previewCache = PreviewCache()

    init(api: ObservabilityAPI) {
        self.api = api
    }

    func search(query: String) async throws -> [SearchMatch] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        let topics = try await api.searchTopics(matching: trimmedQuery)

        return try await withThrowingTaskGroup(of: SearchMatch.self) { group in
            for topic in topics {
                group.addTask { [api, previewCache] in
                    let preview: String
                    if let cached = await previewCache.value(for: topic.id) {
                        preview = cached
                    } else {
                        // Preview work is expensive enough to cache, but still isolated behind an actor.
                        preview = try await api.fetchPreview(for: topic)
                        await previewCache.insert(preview, for: topic.id)
                    }

                    return SearchMatch(
                        id: topic.id,
                        title: topic.title,
                        subtitle: "Relevance \(topic.score)",
                        preview: preview
                    )
                }
            }

            var results: [SearchMatch] = []
            for try await match in group {
                results.append(match)
            }

            // Task groups complete in finish-order, so sort before returning stable UI output.
            return results.sorted { $0.subtitle > $1.subtitle }
        }
    }
}
