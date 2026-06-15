import SwiftUI
import Charts

struct MoodChartView: View {
    let entries: [MoodEntry]
    var days: Int = 14

    private var chartData: [ChartPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<days).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: day) }
            let avgRaw = dayEntries.isEmpty
                ? 0.0
                : Double(dayEntries.map { $0.mood.rawValue }.reduce(0, +)) / Double(dayEntries.count)
            return ChartPoint(date: day, value: avgRaw, hasEntry: !dayEntries.isEmpty)
        }
    }

    var body: some View {
        if chartData.allSatisfy({ !$0.hasEntry }) {
            VStack(spacing: 8) {
                Text("No entries in the last \(days) days")
                    .font(.subheadline)
                    .foregroundStyle(AppPalette.secondaryText)
                Text("Log a mood to see the chart.")
                    .font(.caption)
                    .foregroundStyle(AppPalette.secondaryText)
            }
            .frame(maxWidth: .infinity, minHeight: 180)
            .padding(.vertical, 16)
        } else {
            Chart(chartData) { point in
                if point.hasEntry {
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Mood", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppPalette.accent.opacity(0.5), AppPalette.accent.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Mood", point.value)
                    )
                    .foregroundStyle(AppPalette.accent)
                    .interpolationMethod(.catmullRom)
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Mood", point.value)
                    )
                    .foregroundStyle(moodColor(value: point.value))
                    .symbolSize(80)
                }
            }
            .chartYScale(domain: 0...5)
            .chartYAxis {
                AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let raw = value.as(Int.self), let mood = PlantMood(rawValue: raw) {
                            Text(mood.emoji)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 3)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day().month(.narrow))
                }
            }
            .frame(height: 200)
        }
    }

    private func moodColor(value: Double) -> Color {
        let rounded = max(1, min(5, Int(value.rounded())))
        return PlantMood(rawValue: rounded)?.color ?? AppPalette.accent
    }

    private struct ChartPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
        let hasEntry: Bool
    }
}
