import SwiftUI

struct SearchLabView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    searchHero
                    searchInputCard

                    if viewModel.isSearching {
                        inFlightCard
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    }

                    matchesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.clear)
            .navigationTitle("Search Lab")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .animation(.snappy(duration: 0.3), value: viewModel.isSearching)
        .animation(.snappy(duration: 0.3), value: viewModel.results)
    }

    private var binding: Binding<String> {
        Binding(
            get: { viewModel.query },
            set: { viewModel.updateQuery($0) }
        )
    }

    private var searchHero: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cancellable query pipeline")
                            .font(.title2.weight(.bold))
                        Text("Each keystroke enters an `AsyncStream`, debounces, cancels stale work, and fans out preview requests in parallel.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 12)
                    StatusPill(
                        text: viewModel.isSearching ? "Searching" : "Idle-State",
                        systemImage: viewModel.isSearching ? "waveform.and.magnifyingglass" : "pause.circle.fill",
                        tint: viewModel.isSearching ? AppTheme.accent : .secondary
                    )
                }

                Text(viewModel.statusText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var searchInputCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    eyebrow: "Input",
                    title: "Type quickly to trigger cancellation",
                    detail: "Only the newest debounced query should survive to update the UI."
                )

                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Search concurrency topics", text: binding)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    if !viewModel.query.isEmpty {
                        Button {
                            viewModel.updateQuery("")
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    private var inFlightCard: some View {
        GlassCard {
            HStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Request in flight")
                        .font(.headline)
                    Text("The debounce window closed, the previous task was cancelled, and the latest query is now running.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(
                eyebrow: "Results",
                title: "Parallel preview enrichment",
                detail: "Task-group workers fetch previews concurrently while the cache prevents duplicate work."
            )

            if viewModel.results.isEmpty {
                GlassCard {
                    Text("Results appear here after the stream emits a debounced query.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: 14) {
                    ForEach(viewModel.results) { match in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(match.title)
                                            .font(.headline)
                                        Text(match.subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "sparkles")
                                        .foregroundStyle(AppTheme.accent)
                                }

                                Text(match.preview)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
    }
}
