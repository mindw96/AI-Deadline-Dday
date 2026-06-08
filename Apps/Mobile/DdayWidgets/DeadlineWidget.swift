import SwiftUI
import WidgetKit

struct DeadlineWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: MobileWidgetDeadlineSnapshot
}

struct DeadlineWidgetProvider: TimelineProvider {
    private let store = MobileWidgetSnapshotStore()

    func placeholder(in context: Context) -> DeadlineWidgetEntry {
        DeadlineWidgetEntry(
            date: Date(),
            snapshot: .placeholder
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (DeadlineWidgetEntry) -> Void
    ) {
        completion(
            DeadlineWidgetEntry(
                date: Date(),
                snapshot: store.load() ?? .empty
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<DeadlineWidgetEntry>) -> Void
    ) {
        let now = Date()
        let snapshot = store.load() ?? .empty
        let entry = DeadlineWidgetEntry(date: now, snapshot: snapshot)
        let nextRefresh = nextRefreshDate(now: now, deadline: snapshot.deadlineDate)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func nextRefreshDate(now: Date, deadline: Date) -> Date {
        let remaining = deadline.timeIntervalSince(now)
        if remaining > 0 && remaining <= 24 * 60 * 60 {
            return now.addingTimeInterval(60 * 60)
        }

        let calendar = Calendar.current
        return calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 5),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(60 * 60)
    }
}

struct DeadlineWidget: Widget {
    let kind = "DdayDeadlineWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DeadlineWidgetProvider()) { entry in
            DeadlineWidgetView(entry: entry)
        }
        .configurationDisplayName("Dday")
        .description("Shows your selected conference deadline.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

private struct DeadlineWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DeadlineWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallDeadlineWidget(snapshot: entry.snapshot)
                .containerBackground(.background, for: .widget)
        case .systemMedium:
            MediumDeadlineWidget(snapshot: entry.snapshot)
                .containerBackground(.background, for: .widget)
        case .accessoryCircular:
            CircularDeadlineWidget(snapshot: entry.snapshot)
        case .accessoryRectangular:
            RectangularDeadlineWidget(snapshot: entry.snapshot)
        case .accessoryInline:
            Text("\(entry.snapshot.title) \(entry.snapshot.deadlineText)")
                .font(.headline)
        default:
            SmallDeadlineWidget(snapshot: entry.snapshot)
                .containerBackground(.background, for: .widget)
        }
    }
}

private struct SmallDeadlineWidget: View {
    let snapshot: MobileWidgetDeadlineSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(snapshot.title)
                .font(.title3)
                .fontWeight(.bold)
                .minimumScaleFactor(0.75)
                .lineLimit(1)

            Text(snapshot.deadlineText)
                .font(.system(size: 57, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Spacer(minLength: 0)

            Text(snapshot.deadlineLabel)
                .font(.callout)
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
        }
        .padding(14)
    }
}

private struct MediumDeadlineWidget: View {
    let snapshot: MobileWidgetDeadlineSnapshot

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(snapshot.title)
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(snapshot.deadlineLabel)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.65)
                    .lineLimit(1)

                Text(snapshot.localDateText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Text(snapshot.deadlineText)
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .padding(14)
    }
}

private struct CircularDeadlineWidget: View {
    let snapshot: MobileWidgetDeadlineSnapshot

    var body: some View {
        VStack(spacing: 2) {
            Text(snapshot.title)
                .font(.caption)
                .fontWeight(.bold)
                .minimumScaleFactor(0.65)
                .lineLimit(1)

            Text(snapshot.deadlineText)
                .font(.title3)
                .fontWeight(.bold)
                .monospacedDigit()
                .minimumScaleFactor(0.45)
                .lineLimit(1)
        }
    }
}

private struct RectangularDeadlineWidget: View {
    let snapshot: MobileWidgetDeadlineSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(snapshot.title) \(snapshot.deadlineText)")
                .font(.title3)
                .fontWeight(.bold)
                .monospacedDigit()
                .minimumScaleFactor(0.65)
                .lineLimit(1)

            Text(snapshot.deadlineLabel)
                .font(.callout)
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }
}

#Preview(as: .systemSmall) {
    DeadlineWidget()
} timeline: {
    DeadlineWidgetEntry(date: Date(), snapshot: .placeholder)
}

#Preview(as: .accessoryRectangular) {
    DeadlineWidget()
} timeline: {
    DeadlineWidgetEntry(date: Date(), snapshot: .placeholder)
}
