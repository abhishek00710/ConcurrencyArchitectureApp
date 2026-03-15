import SwiftUI

@main
struct ConcurrencyArchitectureApp: App {
    @StateObject private var dashboardViewModel = DashboardViewModel(
        repository: DashboardRepository(api: MockObservabilityAPI())
    )
    @StateObject private var searchViewModel = SearchViewModel(
        repository: SearchRepository(api: MockObservabilityAPI())
    )

    var body: some Scene {
        WindowGroup {
            RootView(
                dashboardViewModel: dashboardViewModel,
                searchViewModel: searchViewModel
            )
        }
    }
}
