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
  @Relationship(inverse: \Category.shifts)
  private(set) var category: Category?

  init(start: Date, end: Date, notes: String? = nil, tags: [Tag] = [], category: Category? = nil)
    throws
  {
    try Self.checkValues(start: start, end: end, notes: notes)

    self.start = start
    self.end = end
    self.notes = notes
    self.tags = tags
    self.id = UUID()
    self.category = category
  }

  func updateValues(start: Date, end: Date, notes: String?, tags: [Tag], category: Category?) throws
  {
    try Self.checkValues(start: start, end: end, notes: notes)

    self.start = start
    self.end = end
    self.notes = notes
    self.tags = tags
    self.category = category
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
