import Foundation
import SwiftData

enum ShiftCreationError: Error {
  case startIsEnd
  case endBeforeStart
  case moreThanOneDay
}

@Model
final class Shift {
  private(set) var id: UUID
  private(set) var start: Date
  private(set) var end: Date
  private(set) var notes: String?

  @Relationship(inverse: \Tag.shifts)
  private(set) var tags: [Tag] = []

  @Relationship(deleteRule: .cascade, inverse: \ShiftReference.shift)
  private(set) var shiftReference: ShiftReference?

  init(start: Date, end: Date, notes: String? = nil, tags: [Tag] = []) throws {
    try Self.checkValues(start: start, end: end, notes: notes)

    self.start = start
    self.end = end
    self.notes = notes
    self.tags = tags
    self.id = UUID()
  }

  func updateValues(start: Date, end: Date, notes: String?, tags: [Tag]) throws {
    try Self.checkValues(start: start, end: end, notes: notes)

    self.start = start
    self.end = end
    self.notes = notes
    self.tags = tags
  }

  private static func checkValues(start: Date, end: Date, notes: String?) throws {
    guard start != end else {
      throw ShiftCreationError.startIsEnd
    }

    guard start < end else {
      throw ShiftCreationError.endBeforeStart
    }

    let tooLateDate = Calendar.current.date(byAdding: DateComponents(day: 2), to: start)!
    guard end <= tooLateDate else {
      throw ShiftCreationError.moreThanOneDay
    }
  }
}
