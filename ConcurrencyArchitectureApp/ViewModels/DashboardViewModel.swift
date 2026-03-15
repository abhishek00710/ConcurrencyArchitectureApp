import Foundation
import Combine

/// Main-actor UI adapter for the dashboard.
/// The repository does the concurrent work; this type translates it into UI state.
@MainActor
final class DashboardViewModel: ObservableObject {
    private let repository: DashboardRepository
    private var loadTask: Task<Void, Never>?

    @Published var snapshot: DashboardSnapshot?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(repository: DashboardRepository) {
        self.repository = repository
    }

    func load(forceRefresh: Bool = false) {
        // The latest user intent wins; previous visual loads are cancelled.
        loadTask?.cancel()
        loadTask = Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                let snapshot = try await repository.dashboard(forceRefresh: forceRefresh)
                try Task.checkCancellation()
                self.snapshot = snapshot
            } catch is CancellationError {
                return
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
