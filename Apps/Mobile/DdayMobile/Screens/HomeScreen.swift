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
                        UpcomingDeadlinesSection()
                    } else {
                        ContentUnavailableView(
                            model.text.noUpcomingDeadlines,
                            systemImage: "calendar.badge.exclamationmark"
                        )
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.text.upcoming)
                .font(.headline)

            ForEach(model.upcomingSummaries.prefix(6)) { summary in
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
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    HomeScreen()
        .environmentObject(MobileAppModel())
}
