import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard

                    if let snapshot = viewModel.snapshot {
                        metricsGrid(snapshot: snapshot)
                            .transition(.move(edge: .bottom).combined(with: .opacity))

                        trendingTopics(snapshot: snapshot)
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))

                        recentEvents(snapshot: snapshot)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else if viewModel.isLoading {
                        loadingCard
                    } else if let errorMessage = viewModel.errorMessage {
                        messageCard(
                            title: "Load failed",
                            message: errorMessage,
                            systemImage: "wifi.exclamationmark",
                            tint: .red
                        )
                    } else {
                        messageCard(
                            title: "No snapshot yet",
                            message: "Pull to refresh or tap reload. The repository coalesces duplicate requests and caches the latest successful snapshot.",
                            systemImage: "square.stack.3d.up.fill",
                            tint: AppTheme.accent
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .refreshable {
                viewModel.load(forceRefresh: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.clear)
            .navigationTitle("Concurrency Ops")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button("Reload") {
                            viewModel.load(forceRefresh: true)
                        }
                    }
                }
            }
        }
        .task {
            guard viewModel.snapshot == nil else { return }
            viewModel.load()
        }
        .animation(.snappy(duration: 0.35), value: viewModel.isLoading)
        .animation(.snappy(duration: 0.35), value: viewModel.snapshot)
    }

    private var heroCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Advanced Swift Concurrency")
                            .font(.title.weight(.bold))
                        Text("A production-shaped demo of actor isolation, structured concurrency, caching, and cancellation.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 12)

                    if viewModel.isLoading {
                        StatusPill(text: "Refreshing..", systemImage: "arrow.trianglehead.2.clockwise", tint: AppTheme.accent)
                    } else {
                        StatusPill(text: "Actor-backed", systemImage: "shield.lefthalf.filled", tint: .green)
                    }
                }

                Divider()

                Text("The dashboard fans out three async dependencies in parallel, then coalesces overlapping requests into a single shared task.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func metricsGrid(snapshot: DashboardSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(
                eyebrow: "Snapshot",
                title: "Current system health",
                detail: "A single cached snapshot assembled from three parallel async operations."
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                MetricTile(
                    title: "Responders online",
                    value: "\(snapshot.teamHealth.respondersOnline)",
                    systemImage: "person.2.fill",
                    tint: .blue
                )
                MetricTile(
                    title: "Active incidents",
                    value: "\(snapshot.teamHealth.activeIncidents)",
                    systemImage: "exclamationmark.triangle.fill",
                    tint: .red
                )
                MetricTile(
                    title: "Automation coverage",
                    value: "\(snapshot.teamHealth.automationCoverage)%",
                    systemImage: "gearshape.2.fill",
                    tint: .green
                )
                MetricTile(
                    title: "Last refresh",
                    value: snapshot.generatedAt.formatted(date: .omitted, time: .shortened),
                    systemImage: "clock.fill",
                    tint: AppTheme.accent
                )
            }
        }
    }

    private func trendingTopics(snapshot: DashboardSnapshot) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    eyebrow: "Parallel fetch",
                    title: "Trending topics",
                    detail: "Each topic is safe to move across tasks because the model is `Sendable`."
                )

                ForEach(Array(snapshot.trendingTopics.enumerated()), id: \.element.id) { index, topic in
                    HStack(alignment: .center, spacing: 14) {
                        Text("\(index + 1)")
                            .font(.headline.weight(.bold))
                            .frame(width: 34, height: 34)
                            .background(AppTheme.accent.opacity(0.14), in: Circle())
                            .foregroundStyle(AppTheme.accent)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(topic.title)
                                .font(.headline)
                            Text("Priority score \(topic.score)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(.tertiary)
                    }

                    if topic.id != snapshot.trendingTopics.last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    private func recentEvents(snapshot: DashboardSnapshot) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    eyebrow: "Timeline",
                    title: "Recent events",
                    detail: "A lightweight activity log for discussing how the snapshot was assembled."
                )

                ForEach(snapshot.recentEvents) { event in
                    HStack(alignment: .top, spacing: 14) {
                        Circle()
                            .fill(AppTheme.secondaryAccent)
                            .frame(width: 10, height: 10)
                            .padding(.top, 7)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.relativeTime)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                }
            }
        }
    }

    private var loadingCard: some View {
        GlassCard {
            HStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Building snapshot")
                        .font(.headline)
                    Text("Independent services are running in parallel and will merge into a single dashboard state.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func messageCard(title: String, message: String, systemImage: String, tint: Color) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(tint)
                    .frame(width: 46, height: 46)
                    .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
