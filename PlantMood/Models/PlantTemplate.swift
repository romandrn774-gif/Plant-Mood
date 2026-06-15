import Foundation

struct PlantTemplate: Identifiable, Hashable {
    let id: UUID
    var name: String
    var species: String
    var emoji: String
    var defaultWateringIntervalDays: Int
    var lightRequirement: String
    var careLevel: String
    var description: String
    var tips: [String]
    var isPremium: Bool

    init(
        id: UUID = UUID(),
        name: String,
        species: String,
        emoji: String,
        defaultWateringIntervalDays: Int,
        lightRequirement: String,
        careLevel: String,
        description: String,
        tips: [String],
        isPremium: Bool = false
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.emoji = emoji
        self.defaultWateringIntervalDays = defaultWateringIntervalDays
        self.lightRequirement = lightRequirement
        self.careLevel = careLevel
        self.description = description
        self.tips = tips
        self.isPremium = isPremium
    }
}

enum PlantCatalog {
    static let all: [PlantTemplate] = [
        PlantTemplate(
            name: "Monstera",
            species: "Monstera deliciosa",
            emoji: "🌿",
            defaultWateringIntervalDays: 7,
            lightRequirement: "Bright indirect light",
            careLevel: "Easy",
            description: "A tropical vine with split leaves. It likes humidity and filtered light.",
            tips: [
                "Mist the leaves twice a week",
                "Keep it out of direct sunlight",
                "Feed it in spring and summer"
            ]
        ),
        PlantTemplate(
            name: "Succulent",
            species: "Echeveria",
            emoji: "🌵",
            defaultWateringIntervalDays: 14,
            lightRequirement: "Bright light",
            careLevel: "Easy",
            description: "A drought-tolerant plant for sunny windowsills.",
            tips: [
                "Water only when the soil is completely dry",
                "Use good drainage",
                "Barely water it in winter"
            ]
        ),
        PlantTemplate(
            name: "Rubber Plant",
            species: "Ficus elastica",
            emoji: "🌳",
            defaultWateringIntervalDays: 5,
            lightRequirement: "Partial shade",
            careLevel: "Medium",
            description: "A striking ornamental tree with glossy leaves.",
            tips: [
                "Do not move it around often",
                "Wipe the leaves with a damp cloth",
                "Feed it every 2 weeks"
            ]
        ),
        PlantTemplate(
            name: "Orchid",
            species: "Phalaenopsis",
            emoji: "🌸",
            defaultWateringIntervalDays: 7,
            lightRequirement: "Bright indirect light",
            careLevel: "Advanced",
            description: "An elegant flower that needs attention and proper watering.",
            tips: [
                "Water by soaking the pot",
                "Let the roots dry between waterings",
                "Blooming needs a temperature drop"
            ],
            isPremium: true
        ),
        PlantTemplate(
            name: "Cactus",
            species: "Cactaceae",
            emoji: "🌵",
            defaultWateringIntervalDays: 21,
            lightRequirement: "Bright light",
            careLevel: "Easy",
            description: "A hardy spiky plant for beginners.",
            tips: [
                "Very little water",
                "Use a gritty substrate",
                "Direct sun"
            ]
        ),
        PlantTemplate(
            name: "Snake Plant",
            species: "Sansevieria trifasciata",
            emoji: "🌱",
            defaultWateringIntervalDays: 14,
            lightRequirement: "Any light",
            careLevel: "Easy",
            description: "A nearly unkillable plant with upright leaves.",
            tips: [
                "Does not like frequent watering",
                "Helps purify the air",
                "Tolerates partial shade"
            ]
        ),
        PlantTemplate(
            name: "Fern",
            species: "Nephrolepis exaltata",
            emoji: "🌿",
            defaultWateringIntervalDays: 3,
            lightRequirement: "Partial shade",
            careLevel: "Medium",
            description: "Lush greenery with feathery fronds that loves humidity.",
            tips: [
                "High humidity",
                "Mist it regularly",
                "No direct rays"
            ]
        ),
        PlantTemplate(
            name: "Aloe Vera",
            species: "Aloe vera",
            emoji: "🪴",
            defaultWateringIntervalDays: 14,
            lightRequirement: "Bright light",
            careLevel: "Easy",
            description: "A useful succulent with a soothing gel.",
            tips: [
                "Good drainage is required",
                "Do not overwater",
                "Loves sunlight"
            ]
        ),
        PlantTemplate(
            name: "Peace Lily",
            species: "Spathiphyllum",
            emoji: "🌼",
            defaultWateringIntervalDays: 4,
            lightRequirement: "Partial shade",
            careLevel: "Medium",
            description: "White blooms and deep green leaves in one elegant plant.",
            tips: [
                "Likes moist soil",
                "Mist it daily",
                "Can bloom year-round with good care"
            ],
            isPremium: true
        ),
        PlantTemplate(
            name: "Spider Plant",
            species: "Chlorophytum comosum",
            emoji: "🌾",
            defaultWateringIntervalDays: 5,
            lightRequirement: "Any light",
            careLevel: "Easy",
            description: "Ideal for beginners and a great air purifier.",
            tips: [
                "Tolerates a lot",
                "Propagates from plantlets",
                "Likes fresh air"
            ]
        )
    ]
}
