import SwiftUI

@main
struct PlantMoodApp: App {
    @StateObject private var notificationManager = NotificationManager.shared

    init() {
        _ = CoreDataStack.shared
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
                .environmentObject(notificationManager)
                .onAppear {
                    notificationManager.requestAuthorization()
                }
        }
    }
}
