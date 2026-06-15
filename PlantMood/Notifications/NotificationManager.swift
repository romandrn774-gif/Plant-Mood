import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized: Bool = false

    private let center = UNUserNotificationCenter.current()

    private init() {
        refreshAuthorizationStatus()
    }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
            }
        }
    }

    func refreshAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized ||
                    settings.authorizationStatus == .provisional
            }
        }
    }

    func scheduleWateringReminder(for plant: Plant) {
        guard let next = plant.nextWateringDate else { return }
        cancelWateringReminder(plantID: plant.id)

        let content = UNMutableNotificationContent()
        content.title = "Time to water \(plant.name) \(plant.emoji)"
        content.body = "It has been \(plant.wateringIntervalDays) days since the last watering."
        content.sound = .default

        let triggerDate = max(next, Date().addingTimeInterval(60))
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(
            identifier: identifier(plantID: plant.id, kind: "watering"),
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func scheduleFertilizingReminder(for plant: Plant, monthlyOnDay day: Int = 1) {
        cancelFertilizingReminder(plantID: plant.id)

        let content = UNMutableNotificationContent()
        content.title = "Feed \(plant.name) \(plant.emoji)"
        content.body = "A monthly feed will help the plant keep thriving."
        content.sound = .default

        var comps = DateComponents()
        comps.day = day
        comps.hour = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        let request = UNNotificationRequest(
            identifier: identifier(plantID: plant.id, kind: "fertilizing"),
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func cancelWateringReminder(plantID: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(plantID: plantID, kind: "watering")])
    }

    func cancelFertilizingReminder(plantID: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(plantID: plantID, kind: "fertilizing")])
    }

    func cancelAll(for plantID: UUID) {
        cancelWateringReminder(plantID: plantID)
        cancelFertilizingReminder(plantID: plantID)
    }

    private func identifier(plantID: UUID, kind: String) -> String {
        "plantmood.\(kind).\(plantID.uuidString)"
    }
}
