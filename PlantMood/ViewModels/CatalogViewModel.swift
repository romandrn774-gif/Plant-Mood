import Foundation
import Combine

@MainActor
final class CatalogViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var careLevelFilter: String?

    let templates: [PlantTemplate]

    init(templates: [PlantTemplate] = PlantCatalog.all) {
        self.templates = templates
    }

    var filtered: [PlantTemplate] {
        var result = templates
        if let level = careLevelFilter {
            result = result.filter { $0.careLevel == level }
        }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.species.lowercased().contains(query)
            }
        }
        return result
    }

    var availableCareLevels: [String] {
        Array(Set(templates.map { $0.careLevel })).sorted()
    }

    func plant(from template: PlantTemplate) -> Plant {
        Plant(
            name: template.name,
            species: template.species,
            emoji: template.emoji,
            wateringIntervalDays: template.defaultWateringIntervalDays,
            isPremium: template.isPremium
        )
    }
}
