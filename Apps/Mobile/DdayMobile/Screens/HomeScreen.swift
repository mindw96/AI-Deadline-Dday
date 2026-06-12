import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var model: MobileAppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let errorMessage = model.errorMessage {
                        ContentUnavailableView(
                            model.text.conferenceDataUnavailable,
                            systemImage: "exclamationmark.triangle",
                            description: Text(errorMessage)
                        )
                    } else if let summary = model.featuredSummary {
                        DeadlineHero(summary: summary)
                    } else {
                        ContentUnavailableView(
                            model.text.noMainDday,
                            systemImage: "pin",
                            description: Text(model.text.noMainDdayDescription)
                        )
                    }

                    if model.errorMessage == nil {
                        if model.upcomingSummaries.isEmpty {
                            ContentUnavailableView(
                                model.text.noUpcomingDeadlines,
                                systemImage: "calendar.badge.exclamationmark"
                            )
                        } else {
                            UpcomingDeadlinesSection()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(model.text.homeTitle)
        }
    }
}

private struct DeadlineHero: View {
    @EnvironmentObject private var model: MobileAppModel
    let summary: MobileDeadlineSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(model.text.mainDeadline)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text(summary.title)
                .font(.title)
                .fontWeight(.bold)

            DeadlineBadgeView(text: summary.display.text)

            VStack(alignment: .leading, spacing: 6) {
                Text(summary.deadlineLabel)
                    .font(.headline)
                Text(summary.localDateText)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct UpcomingDeadlinesSection: View {
    @EnvironmentObject private var model: MobileAppModel
    @State private var collapsedGroupIDs: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.text.upcoming)
                .font(.headline)

            let customSummaries = model.customDeadlineSummaries
                .filter { $0.display.remainingSeconds > 0 }
            if !customSummaries.isEmpty {
                UpcomingDeadlineGroup(
                    id: "custom",
                    title: model.text.customTitle,
                    summaries: customSummaries,
                    collapsedGroupIDs: $collapsedGroupIDs
                )
            }

            ForEach(model.selectedSubcategories, id: \.rawValue) { subcategory in
                let summaries = model.upcomingSummaries(in: subcategory)
                if !summaries.isEmpty {
                    UpcomingDeadlineGroup(
                        id: subcategory.rawValue,
                        title: model.text.subcategoryTitle(subcategory),
                        summaries: summaries,
                        collapsedGroupIDs: $collapsedGroupIDs
                    )
                }
            }
        }
    }
}

private struct UpcomingDeadlineGroup: View {
    let id: String
    let title: String
    let summaries: [MobileDeadlineSummary]
    @Binding var collapsedGroupIDs: Set<String>

    private var isExpanded: Bool {
        !collapsedGroupIDs.contains(id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.snappy) {
                    if isExpanded {
                        collapsedGroupIDs.insert(id)
                    } else {
                        collapsedGroupIDs.remove(id)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("\(summaries.count)")
                        .font(.caption2.monospacedDigit())
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            if isExpanded {
                ForEach(summaries) { summary in
                    UpcomingDeadlineRow(summary: summary)
                }
            }
        }
    }
}

private struct UpcomingDeadlineRow: View {
    @EnvironmentObject private var model: MobileAppModel
    let summary: MobileDeadlineSummary

    var body: some View {
        Button {
            model.select(summary.source)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(summary.title)
                        .fontWeight(.semibold)
                    Text(summary.deadlineLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(summary.display.text)
                    .font(.headline.monospacedDigit())
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    HomeScreen()
        .environmentObject(MobileAppModel())
}
