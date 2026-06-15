import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppPalette.card)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            NavigationStack {
                PlantListView()
            }
            .tabItem {
                Label("Plants", systemImage: "leaf.fill")
            }

            NavigationStack {
                WateringCalendarView()
            }
            .tabItem {
                Label("Watering", systemImage: "drop.fill")
            }

            NavigationStack {
                PhotoDiaryView()
            }
            .tabItem {
                Label("Diary", systemImage: "photo.on.rectangle")
            }

            NavigationStack {
                CatalogView()
            }
            .tabItem {
                Label("Catalog", systemImage: "books.vertical.fill")
            }
        }
        .tint(AppPalette.accent)
    }
}
