import SwiftUI

struct WateringCalendarView: View {
    @StateObject private var viewModel = WateringViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !viewModel.overdue.isEmpty {
                    overdueSection
                }
                upcomingSection
                if viewModel.plants.isEmpty {
                    EmptyStateView(
                        emoji: "💧",
                        title: "No plants",
                        message: "Add plants in the Plants tab to see the watering calendar."
                    )
                    .padding(.top, 40)
                }
            }
            .padding(16)
        }
        .background(AppPalette.background.ignoresSafeArea())
        .navigationTitle("Watering")
        .onAppear { viewModel.load() }
        .refreshable { viewModel.load() }
    }

    private var overdueSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(AppPalette.warning)
                Text("Overdue")
                    .font(.headline)
                    .foregroundStyle(AppPalette.primaryText)
            }
            ForEach(viewModel.overdue) { plant in
                HStack(spacing: 12) {
                    Text(plant.emoji).font(.system(size: 32))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(plant.name).font(.subheadline.weight(.semibold))
                        if let days = plant.daysUntilWatering {
                            Text("Overdue by \(-days) days")
                                .font(.caption)
                                .foregroundStyle(AppPalette.warning)
                        }
                    }
                    Spacer()
                    Button {
                        viewModel.waterToday(plant: plant)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                            Text("Water")
                        }
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppPalette.waterBlue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppPalette.warning.opacity(0.1))
                )
            }
        }
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundStyle(AppPalette.waterBlue)
                Text("Next 14 days")
                    .font(.headline)
                    .foregroundStyle(AppPalette.primaryText)
            }
            ForEach(viewModel.upcomingDays) { day in
                WateringDayRow(day: day) { plant in
                    viewModel.waterToday(plant: plant)
                }
            }
        }
    }
}

private struct WateringDayRow: View {
    let day: WateringDay
    let onWater: (Plant) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 2) {
                Text(weekdayString)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppPalette.secondaryText)
                Text(dayString)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(day.isToday ? .white : AppPalette.primaryText)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(day.isToday ? AppPalette.accent : AppPalette.accent.opacity(0.12))
                    )
            }
            .frame(width: 56)

            VStack(alignment: .leading, spacing: 6) {
                if day.plants.isEmpty {
                    Text("Free day")
                        .font(.subheadline)
                        .foregroundStyle(AppPalette.secondaryText)
                } else {
                    ForEach(day.plants) { plant in
                        HStack {
                            Text(plant.emoji)
                            Text(plant.name)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppPalette.primaryText)
                            Spacer()
                            if day.isToday {
                                Button {
                                    onWater(plant)
                                } label: {
                                    Image(systemName: "drop.fill")
                                        .foregroundStyle(.white)
                                        .padding(8)
                                        .background(Circle().fill(AppPalette.waterBlue))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppPalette.card)
        )
    }

    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EE"
        return formatter.string(from: day.date).uppercased()
    }

    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: day.date)
    }
}
