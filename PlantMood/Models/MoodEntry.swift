import SwiftUI

enum PlantMood: Int, CaseIterable, Codable, Identifiable {
    case wilting = 1
    case sad = 2
    case neutral = 3
    case good = 4
    case flourishing = 5

    var id: Int { rawValue }

    var emoji: String {
        switch self {
        case .wilting: return "🥀"
        case .sad: return "😔"
        case .neutral: return "🌿"
        case .good: return "🌼"
        case .flourishing: return "🌸"
        }
    }

    var label: String {
        switch self {
        case .wilting: return "Wilting"
        case .sad: return "Sad"
        case .neutral: return "Neutral"
        case .good: return "Healthy"
        case .flourishing: return "Blooming"
        }
    }

    var color: Color {
        switch self {
        case .wilting: return Color(hex: "#8B4A4A")
        case .sad: return Color(hex: "#A0856C")
        case .neutral: return Color(hex: "#6B8F6B")
        case .good: return Color(hex: "#D4A843")
        case .flourishing: return Color(hex: "#E8708A")
        }
    }
}

struct MoodEntry: Identifiable, Hashable {
    let id: UUID
    let plantID: UUID
    var mood: PlantMood
    var note: String
    var date: Date
    var photoData: Data?

    init(
        id: UUID = UUID(),
        plantID: UUID,
        mood: PlantMood,
        note: String = "",
        date: Date = Date(),
        photoData: Data? = nil
    ) {
        self.id = id
        self.plantID = plantID
        self.mood = mood
        self.note = note
        self.date = date
        self.photoData = photoData
    }
}
