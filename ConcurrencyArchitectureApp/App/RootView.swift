import SwiftUI

struct RootView: View {
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @ObservedObject var searchViewModel: SearchViewModel

    var body: some View {
        TabView {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }

            SearchLabView(viewModel: searchViewModel)
                .tabItem {
                    Label("Search Lab", systemImage: "bolt.horizontal.circle.fill")
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            AppBackground()
        }
        .toolbarBackground(.hidden, for: .tabBar)
        .tint(AppTheme.accent)
    }
}
