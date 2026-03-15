import Foundation
import Combine

/// Coordinates a debounced, cancellable live-search pipeline for the search tab.
@MainActor
final class SearchViewModel: ObservableObject {
    private let repository: SearchRepository
    private let queryChannel = QueryChannel()

    private var streamTask: Task<Void, Never>?
    private var requestTask: Task<Void, Never>?
    private var latestIssuedQuery = ""

    @Published var query = ""
    @Published var results: [SearchMatch] = []
    @Published var isSearching = false
    @Published var statusText = "Type to start the async pipeline."

    init(repository: SearchRepository) {
        self.repository = repository
        bindQueryStream()
    }

    deinit {
        streamTask?.cancel()
        requestTask?.cancel()
    }

    func updateQuery(_ query: String) {
        self.query = query
        Task {
            await queryChannel.send(query)
        }
    }

    private func bindQueryStream() {
        streamTask = Task { [queryChannel] in
            for await query in await queryChannel.stream {
                // Cancel stale requests as soon as fresher input arrives.
                requestTask?.cancel()

                requestTask = Task { [repository] in
                    do {
                        // Manual debounce keeps the async pipeline visible for teaching purposes.
                        try await Task.sleep(for: .milliseconds(350))
                        try Task.checkCancellation()

                        await MainActor.run {
                            self.latestIssuedQuery = query
                            self.isSearching = !query.isEmpty
                            self.statusText = query.isEmpty ? "Type to start the async pipeline." : "Searching for \"\(query)\""
                        }

                        let results = try await repository.search(query: query)
                        try Task.checkCancellation()

                        await MainActor.run {
                            // Ignore late arrivals that completed after a newer query was issued.
                            guard self.latestIssuedQuery == query else { return }
                            self.results = results
                            self.isSearching = false
                            self.statusText = results.isEmpty ? "No results for \"\(query)\"." : "Loaded \(results.count) result(s) with parallel preview fetches."
                        }
                    } catch is CancellationError {
                        await MainActor.run {
                            self.isSearching = false
                        }
                    } catch {
                        await MainActor.run {
                            self.isSearching = false
                            self.results = []
                            self.statusText = "Search failed: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
    }
}
