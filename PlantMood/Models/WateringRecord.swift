import Foundation

struct WateringRecord: Identifiable, Hashable {
    let id: UUID
    let plantID: UUID
    var date: Date
    var note: String

    init(id: UUID = UUID(), plantID: UUID, date: Date = Date(), note: String = "") {
        self.id = id
        self.plantID = plantID
        self.date = date
        self.note = note
    }
}
